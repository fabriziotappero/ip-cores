-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_SEQ.vhd,v 1.1 2005/12/06 13:00:24 tame Exp $ 
--
 
----- cell gsr -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
 
 
-- entity declaration --
ENTITY gsr IS
   GENERIC(
      timingcheckson  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "gsr");
 
   PORT(
      gsr             : IN std_logic := 'Z');

END gsr;
 
-- architecture body --
ARCHITECTURE v OF gsr IS
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   --  empty
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   gsrnet <= gsr;
 
END v;


--
----- cell pur -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.purnet;
 
 
-- entity declaration --
ENTITY pur IS
   GENERIC(
      timingcheckson  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "pur");
 
   PORT(
      pur             : IN std_logic := 'Z');
 
END pur;
 
-- architecture body --
ARCHITECTURE v OF pur IS
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   --  empty
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   purnet <= pur;
 
END v;


--
----- cell fd1p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3ax IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3ax";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge	: VitalDelayType := 0.001 ns;
        tpw_ck_negedge	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3ax : ENTITY IS TRUE;

END fd1p3ax ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3ax IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  clr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q 	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q 	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, 
            TestSignalname => "d", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1'),
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, 
            TestSignalname => "sp", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_sp OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, 
      XOn => XOn, 
      MsgOn => MsgOn);
 
END PROCESS;
 
END v;


--
----- cell fd1p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3ay";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3ay : ENTITY IS TRUE;

END fd1p3ay ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  pre  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, 
            TestSignalname => "d", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1'),
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, 
            TestSignalname => "sp", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_sp OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, 
      XOn => XOn, 
      MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3bx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3bx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3bx : ENTITY IS TRUE;

END fd1p3bx ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  pre  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '-', '1', '0' ),  -- async. preset 
	( '-', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '0', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, 
            TestSignalname => "d", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, 
            TestSignalname => "sp", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, 
            TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_sp OR tviol_ck OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => pd_ipd);  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, preset, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, 
      XOn => XOn, 
      MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3dx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3dx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3dx : ENTITY IS TRUE;

END fd1p3dx ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  clr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '-', '0', '1' ),  -- async. clear 
	( '-', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '0', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear	: std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, 
            TestSignalname => "d", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, 
            TestSignalname => "sp", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_sp OR tviol_ck OR tviol_cd;
 
    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
    clear := VitalOR2 (a => not(set_reset), b => cd_ipd);  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, clear, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, 
      XOn => XOn, 
      MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3ix IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3ix";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_cd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3ix : ENTITY IS TRUE;

END fd1p3ix ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 9) := (
      -- viol  clr  scl  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '0', '1' ),  -- sync. clear 
	( '-', '1', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tsviol_cd   : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, 
            TestSignalname => "d", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', 
            MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, 
            TestSignalname => "cd",
            RefSignal => ck_ipd, 
            RefSignalName => "ck",
            SetupHigh => tsetup_cd_ck_noedge_posedge, 
            SetupLow => tsetup_cd_ck_noedge_posedge,
            HoldHigh => thold_cd_ck_noedge_posedge, 
            HoldLow => thold_cd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/',
            MsgOn => MsgOn, 
            XOn => XOn,
            HeaderMsg => InstancePath, 
            TimingData => cd_ck_timingdatash,
            Violation => tsviol_cd, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, 
            TestSignalname => "sp", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn,
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, 
            XOn => XOn,
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tsviol_cd OR tviol_sp OR tviol_ck OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, cd_ipd, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1p3jx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1p3jx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_pd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1p3jx : ENTITY IS TRUE;

END fd1p3jx ;
 
-- architecture body --
ARCHITECTURE v OF fd1p3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, ck_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 9) := (
      -- viol  pre  spr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '1', '0' ),  -- sync. preset
	( '-', '1', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalname => "pd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_pd_ck_noedge_posedge, 
            SetupLow => tsetup_pd_ck_noedge_posedge,
            HoldHigh => thold_pd_ck_noedge_posedge, 
            HoldLow => thold_pd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_ck_timingdatash,
            Violation => tsviol_pd, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalname => "sp", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_ck_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, 
            TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tsviol_pd OR tviol_sp OR tviol_ck OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, pd_ipd, sp_ipd, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell fd1s1a -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1a IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1a";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1a : ENTITY IS TRUE;

END fd1s1a ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1a IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s1ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1ay";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1ay : ENTITY IS TRUE;

END fd1s1ay ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s1b -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1b IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1b";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1b : ENTITY IS TRUE;

END fd1s1b ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1b IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '1', '0' ),  -- async. preset 
	( '-', '0', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '1', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => pd_ipd);  

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, preset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s1d -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1d IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1d";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1d : ENTITY IS TRUE;

END fd1s1d ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1d IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '0', '1' ),  -- async. clear 
	( '-', '0', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '1', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => not(set_reset), b => cd_ipd);  

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, clear, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

 
END PROCESS;
 
END v;


--
----- cell fd1s1i -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1i IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1i";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_cd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge          : VitalDelayType := 0.001 ns;
        tpw_cd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1i : ENTITY IS TRUE;

END fd1s1i ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1i IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, cd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
        ( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tsviol_cd   : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalname => "cd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_cd_ck_noedge_negedge, 
            SetupLow => tsetup_cd_ck_noedge_negedge,
            HoldHigh => thold_cd_ck_noedge_negedge, 
            HoldLow => thold_cd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_ck_timingdatash,
            Violation => tsviol_cd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, 
            XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tsviol_cd OR tviol_ck OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synclr := VitalAND2 (a => d_ipd, b => not(cd_ipd));  

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, synclr),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s1j -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s1j IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s1j";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_pd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s1j : ENTITY IS TRUE;

END fd1s1j ;
 
-- architecture body --
ARCHITECTURE v OF fd1s1j IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, pd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
        ( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_negedge, 
            SetupLow => tsetup_d_ck_noedge_negedge,
            HoldHigh => thold_d_ck_noedge_negedge, 
            HoldLow => thold_d_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalname => "pd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_pd_ck_noedge_negedge, 
            SetupLow => tsetup_pd_ck_noedge_negedge,
            HoldHigh => thold_pd_ck_noedge_negedge, 
            HoldLow => thold_pd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_ck_timingdatash,
            Violation => tsviol_pd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tsviol_pd OR tviol_ck OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synpre := VitalOR2 (a => d_ipd, b => pd_ipd);  

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, synpre),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3ax IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3ax";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3ax : ENTITY IS TRUE;

END fd1s3ax ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3ax IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3ay";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3ay : ENTITY IS TRUE;

END fd1s3ay ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3bx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3bx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3bx : ENTITY IS TRUE;

END fd1s3bx ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '1', '0' ),  -- async. preset 
	( '-', '0', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '0', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => pd_ipd);  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, preset, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3dx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3dx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3dx : ENTITY IS TRUE;

END fd1s3dx ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '0', '1' ),  -- async. clear
	( '-', '0', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '0', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '0', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '0', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_ck OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => not(set_reset), b => cd_ipd);  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, clear, ck_ipd, d_ipd),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3ix IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3ix";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_cd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3ix : ENTITY IS TRUE;

END fd1s3ix ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tsviol_cd   : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_ck_TimingDatash      : VitalTimingDataType;
   VARIABLE cd_ck_TimingDatash      : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalname => "cd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_cd_ck_noedge_posedge, 
            SetupLow => tsetup_cd_ck_noedge_posedge,
            HoldHigh => thold_cd_ck_noedge_posedge, 
            HoldLow => thold_cd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, 
            TimingData => cd_ck_timingdatash,
            Violation => tsviol_cd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_posedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_cd OR tviol_ck OR tsviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synclr := VitalAND2 (a => d_ipd, b => not(cd_ipd));  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, synclr),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fd1s3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fd1s3jx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fd1s3jx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_pd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        ck              : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fd1s3jx : ENTITY IS TRUE;

END fd1s3jx ;
 
-- architecture body --
ARCHITECTURE v OF fd1s3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising edge ck
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising edge ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE d_ck_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalname => "d", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d_ck_noedge_posedge, 
            SetupLow => tsetup_d_ck_noedge_posedge,
            HoldHigh => thold_d_ck_noedge_posedge, 
            HoldLow => thold_d_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d_ck_timingdatash, 
	    Violation => tviol_d, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_pd_ck_noedge_posedge, 
            SetupLow => tsetup_pd_ck_noedge_posedge,
            HoldHigh => thold_pd_ck_noedge_posedge, 
            HoldLow => thold_pd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => pd_ck_timingdatash, 
	    Violation => tsviol_pd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, 
            TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d OR tviol_pd OR tviol_ck OR tsviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synpre := VitalOR2 (a => d_ipd, b => pd_ipd);  

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, synpre),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3ay";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3ay : ENTITY IS TRUE;

END fl1p3ay ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  pre  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, 
            TestSignalname => "d0", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1' AND sd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, 
            TestSignalname => "d1", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1' AND sd_ipd='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, 
            TestSignalname => "sp", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, 
            TestSignalname => "sd", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1p3az -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3az IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3az";
        -- propagation delayS
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3az : ENTITY IS TRUE;

END fl1p3az ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3az IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  clr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, 
            TestSignalname => "d0", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1' AND sd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, 
            TestSignalname => "d1", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sp_ipd='1' AND sd_ipd='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, 
            TestSignalname => "sp", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, 
            TestSignalname => "sd", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3bx IS
    GENERIC (


        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3bx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
	sd              : IN std_logic;
	pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3bx : ENTITY IS TRUE;

END fl1p3bx ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, pd_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  pre  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '-', '1', '0' ),  -- async. preset
	( '-', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '0', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, 
            TestSignalname => "d0", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1' 
                             AND sd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, 
            TestSignalname => "d1", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1' 
                             AND sd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, 
            TestSignalname => "sp", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, 
            TestSignalname => "sd", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, 
            TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, 
            Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_sd OR tviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => pd_ipd);

    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, preset, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
                3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3dx IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3dx";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
	sd              : IN std_logic;
	cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3dx : ENTITY IS TRUE;

END fl1p3dx ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, cd_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 8) := (
      -- viol  clr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '-', '0', '1' ),  -- async. clear
	( '-', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '0', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, 
            TestSignalname => "d0", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (purnet='1' AND cd_ipd='0' AND sp_ipd='1' 
                             AND sd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, 
            TestSignalname => "d1", 
	    RefSignal => ck_ipd, 
            RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (purnet='1' AND cd_ipd='0' AND sp_ipd='1' 
                             AND sd_ipd='1'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, 
            TestSignalname => "sp", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (purnet='1' AND cd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, 
            MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, 
            TestSignalname => "sd", 
            RefSignal => ck_ipd, 
            RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (purnet='1' AND cd_ipd='0'), 
            RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, 
            TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, 
            MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, 
            TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, 
            Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, 
            TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, 
            Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, 
            CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_sd OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => cd_ipd);

    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, preset, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
                3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1p3iy -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3iy IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3iy";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
	tsetup_cd_ck_noedge_posedge     : VitalDelayType := 0.0 ns;
        thold_cd_ck_noedge_posedge      : VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
	sd              : IN std_logic;
	cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3iy : ENTITY IS TRUE;

END fl1p3iy ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3iy IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, cd_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 9) := (
      -- viol  clr  scl  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '0', '1' ),  -- sync. clear
	( '-', '1', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tsviol_cd   : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE cd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='1' AND sp_ipd='1' 
                             AND sd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='1' AND sp_ipd='1' 
                             AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalname => "cd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_cd_ck_noedge_posedge, 
            SetupLow => tsetup_cd_ck_noedge_posedge,
            HoldHigh => thold_cd_ck_noedge_posedge, 
            HoldLow => thold_cd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_ck_timingdatash,
            Violation => tsviol_cd, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalname => "sp", 
            RefSignal => ck_ipd, RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, TestSignalname => "sd", 
            RefSignal => ck_ipd, RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_cd OR tviol_sd OR tsviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, cd_ipd, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
                3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell fl1p3jy -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1p3jy IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1p3jy";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
	tsetup_pd_ck_noedge_posedge     : VitalDelayType := 0.0 ns;
        thold_pd_ck_noedge_posedge      : VitalDelayType := 0.0 ns;
        tsetup_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sp              : IN std_logic;
        ck              : IN std_logic;
	sd              : IN std_logic;
	pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1p3jy : ENTITY IS TRUE;

END fl1p3jy ;
 
-- architecture body --
ARCHITECTURE v OF fl1p3jy IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, pd_ipd, sd_ipd, sp_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 9) := (
      -- viol  pre  spr  ce   ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '1', '0' ),  -- sync. preset
	( '-', '1', '0', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '0', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '0', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE pd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sp_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='1' AND sp_ipd='1' 
                             AND sd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='1' AND sp_ipd='1' 
                             AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalname => "pd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_pd_ck_noedge_posedge, 
            SetupLow => tsetup_pd_ck_noedge_posedge,
            HoldHigh => thold_pd_ck_noedge_posedge, 
            HoldLow => thold_pd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_ck_timingdatash,
            Violation => tsviol_pd, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalname => "sp", 
            RefSignal => ck_ipd, RefSignalName => "ck", 
            SetupHigh => tsetup_sp_ck_noedge_posedge, 
            SetupLow => tsetup_sp_ck_noedge_posedge,
            HoldHigh => thold_sp_ck_noedge_posedge, 
            HoldLow => thold_sp_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, TimingData => sp_ck_timingdatash, 
            Violation => tviol_sp, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, TestSignalname => "sd", 
            RefSignal => ck_ipd, RefSignalName => "ck", 
            SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
            MsgOn => MsgOn, XOn => XOn, 
            HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
            Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sp OR tviol_pd OR tviol_sd OR tsviol_pd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, pd_ipd, sp_ipd, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
                3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell fl1s1a -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1a IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1a";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1a : ENTITY IS TRUE;

END fl1s1a ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1a IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s1ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1ay";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1ay : ENTITY IS TRUE;

END fl1s1ay ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		5 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s1b -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1b IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1b";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	pd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1b : ENTITY IS TRUE;

END fl1s1b ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1b IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, pd_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '1', '0' ),  -- async. preset 
	( '-', '0', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '0', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '0', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_pd OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => not(set_reset), b => pd_ipd);

    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, preset, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
                4 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		5 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		6 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s1d -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1d IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1d";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	cd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1d : ENTITY IS TRUE;

END fl1s1d ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1d IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, cd_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '1', '-', '-', '-', '0', '1' ),  -- async. clear 
	( '-', '0', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '0', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '0', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear       : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sd OR tviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => not(set_reset), b => cd_ipd);

    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, clear, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
                4 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		5 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		6 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s1i -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1i IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1i";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_ck_noedge_negedge     : VitalDelayType := 0.0 ns;
        thold_cd_ck_noedge_negedge      : VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge     : VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge      : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_cd      	: VitalDelayType := 0.001 ns;
        tpw_cd_posedge		: VitalDelayType := 0.001 ns;
        tpw_cd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	cd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1i : ENTITY IS TRUE;

END fl1s1i ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1i IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, cd_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tsviol_cd   : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE cd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr      : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalname => "cd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_cd_ck_noedge_negedge, 
            SetupLow => tsetup_cd_ck_noedge_negedge,
            HoldHigh => thold_cd_ck_noedge_negedge, 
            HoldLow => thold_cd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_ck_timingdatash,
            Violation => tsviol_cd, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, TestSignalname => "sd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash,
            Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => cd_ipd, TestSignalname => "cd", 
	    Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge, 
	    PulseWidthLow => tpw_cd_negedge, 
	    Perioddata => periodcheckinfo_cd, Violation => tviol_cd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_cd OR tviol_ck OR tviol_sd OR tsviol_cd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    synclr := VitalAND2 (a => muxout, b => not(cd_ipd));

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, synclr),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		5 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		6 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

 
END PROCESS;
 
END v;


--
----- cell fl1s1j -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s1j IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s1j";
        -- propagation delays
        tpd_d0_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d1_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_ck_noedge_negedge    : VitalDelayType := 0.0 ns;
        thold_pd_ck_noedge_negedge     : VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_negedge    : VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_negedge     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns;
        tperiod_pd      	: VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
	pd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s1j : ENTITY IS TRUE;

END fl1s1j ;
 
-- architecture body --
ARCHITECTURE v OF fl1s1j IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, pd_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', 'S', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0', '1' ),  -- low d->q on high ck
	( '-', '1', '1', '1', '-', '1', '0' ),  -- high d->q on high ck
	( '-', '1', '1', 'X', '-', 'X', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE pd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre      : std_logic := 'X';
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_negedge, 
            SetupLow => tsetup_d0_ck_noedge_negedge,
            HoldHigh => thold_d0_ck_noedge_negedge, 
            HoldLow => thold_d0_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_negedge, 
            SetupLow => tsetup_d1_ck_noedge_negedge,
            HoldHigh => thold_d1_ck_noedge_negedge, 
            HoldLow => thold_d1_ck_noedge_negedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalname => "pd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_pd_ck_noedge_negedge, 
            SetupLow => tsetup_pd_ck_noedge_negedge,
            HoldHigh => thold_pd_ck_noedge_negedge, 
            HoldLow => thold_pd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_ck_timingdatash,
            Violation => tsviol_pd, MsgSeverity => Warning);
        VitalSetupHoldCheck (
            TestSignal => sd_ipd, TestSignalname => "sd",
            RefSignal => ck_ipd, RefSignalName => "ck",
            SetupHigh => tsetup_sd_ck_noedge_negedge, 
            SetupLow => tsetup_sd_ck_noedge_negedge,
            HoldHigh => thold_sd_ck_noedge_negedge, 
            HoldLow => thold_sd_ck_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash,
            Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => pd_ipd, TestSignalname => "pd", 
	    Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge, 
	    PulseWidthLow => tpw_pd_negedge, 
	    Perioddata => periodcheckinfo_pd, Violation => tviol_pd, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_pd OR tviol_ck OR tsviol_pd OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    synpre := VitalOR2 (a => muxout, b => pd_ipd);

    VitalStateTable (StateTable => latch_table,
	    DataIn => (Violation, set_reset, ck_ipd, synpre),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (d0_ipd'last_event, tpd_d0_q, TRUE),
		2 => (d1_ipd'last_event, tpd_d1_q, TRUE),
		3 => (sd_ipd'last_event, tpd_sd_q, TRUE),
		4 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		5 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		6 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s3ax IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s3ax";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s3ax : ENTITY IS TRUE;

END fl1s3ax ;
 
-- architecture body --
ARCHITECTURE v OF fl1s3ax IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  clr  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '0', '1' ),  -- async. clear (active low)
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "01";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell fl1s3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY fl1s3ay IS
    GENERIC (

        gsr             : String  := "ENABLED";

        timingcheckson	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "fl1s3ay";
        -- propagation delays
        tpd_ck_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d0_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d1_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sd_ck_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d0		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_d1		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_ck      	: VitalDelayType := 0.001 ns;
        tpw_ck_posedge		: VitalDelayType := 0.001 ns;
        tpw_ck_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d0              : IN std_logic;
        d1              : IN std_logic;
	sd              : IN std_logic;
        ck              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF fl1s3ay : ENTITY IS TRUE;

END fl1s3ay ;
 
-- architecture body --
ARCHITECTURE v OF fl1s3ay IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d0_ipd  : std_logic := '0';
    SIGNAL d1_ipd  : std_logic := '0';
    SIGNAL sd_ipd  : std_logic := '0';
    SIGNAL ck_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d0_ipd, d0, tipd_d0);
       VitalWireDelay(d1_ipd, d1, tipd_d1);
       VitalWireDelay(sd_ipd, sd, tipd_sd);
       VitalWireDelay(ck_ipd, ck, tipd_ck);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd, ck_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 6, 1 to 7) := (
      -- viol  pre  ck    d    q  qnew qnnew
	( 'X', '-', '-', '-', '-', 'X', 'X' ),  -- timing Violation
	( '-', '0', '-', '-', '-', '1', '0' ),  -- async. preset (active low)
	( '-', '1', '/', '0', '-', '0', '1' ),  -- low d->q on rising ck
	( '-', '1', '/', '1', '-', '1', '0' ),  -- high d->q on rising ck
	( '-', '1', '/', 'X', '-', 'X', 'X' ),  -- clock an x if d is x
	( '-', '1', 'B', '-', '-', 'S', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_ck    : X01 := '0';
   VARIABLE tviol_d0    : X01 := '0';
   VARIABLE tviol_d1    : X01 := '0';
   VARIABLE tviol_sd    : X01 := '0';
   VARIABLE d0_ck_TimingDatash : VitalTimingDataType;
   VARIABLE d1_ck_TimingDatash : VitalTimingDataType;
   VARIABLE sd_ck_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_ck : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE Violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 2) := "10";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE muxout      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (timingcheckson) THEN
        VitalSetupHoldCheck (
	    TestSignal => d0_ipd, TestSignalname => "d0", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d0_ck_noedge_posedge, 
            SetupLow => tsetup_d0_ck_noedge_posedge,
            HoldHigh => thold_d0_ck_noedge_posedge, 
            HoldLow => thold_d0_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d0_ck_timingdatash, 
	    Violation => tviol_d0, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => d1_ipd, TestSignalname => "d1", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_d1_ck_noedge_posedge, 
            SetupLow => tsetup_d1_ck_noedge_posedge,
            HoldHigh => thold_d1_ck_noedge_posedge, 
            HoldLow => thold_d1_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d1_ck_timingdatash, 
	    Violation => tviol_d1, MsgSeverity => Warning);
        VitalSetupHoldCheck (
	    TestSignal => sd_ipd, TestSignalname => "sd", 
	    RefSignal => ck_ipd, RefSignalName => "ck", 
	    SetupHigh => tsetup_sd_ck_noedge_posedge, 
            SetupLow => tsetup_sd_ck_noedge_posedge,
            HoldHigh => thold_sd_ck_noedge_posedge, 
            HoldLow => thold_sd_ck_noedge_posedge,
            CheckEnabled => (set_reset='1' AND sd_ipd='1'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sd_ck_timingdatash, 
	    Violation => tviol_sd, MsgSeverity => Warning);
        VitalPeriodPulseCheck (
	    TestSignal => ck_ipd, TestSignalname => "ck", 
	    Period => tperiod_ck,
            PulseWidthHigh => tpw_ck_posedge, 
	    PulseWidthLow => tpw_ck_negedge, 
	    Perioddata => periodcheckinfo_ck, Violation => tviol_ck, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => Warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    Violation := tviol_d0 OR tviol_d1 OR tviol_ck OR tviol_sd;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    muxout := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

    VitalStateTable (StateTable => ff_table,
	    DataIn => (Violation, set_reset, ck_ipd, muxout),
	    Numstates => 1,
	    Result =>results,
	    PreviousDataIn => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalname => "q",
      OutTemp => q_zd,
      Paths => (0 => (InputChangeTime => ck_ipd'last_event, 
	              PathDelay => tpd_ck_q, 
		      PathCondition => TRUE),
		1 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		2 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

 
END PROCESS;
 
END v;



-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_IO.vhd,v 1.1 2005/12/06 13:00:23 tame Exp $ 
--
 
--
----- cell tsall -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;
 
 
-- entity declaration --
ENTITY tsall IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "tsall");
 
   PORT(
      tsall           : IN std_logic := 'Z');

END tsall;
 
-- architecture body --
ARCHITECTURE v OF tsall IS
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   --  empty
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   tsallnet <= tsall;
 
END v;

 
--
----- cell bb -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY bb IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "bb";
      tpd_i_b         :  VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_b         :  VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_b_o         :  VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_b          :  VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :  VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :  VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      b               :  INOUT std_logic;
      i               :  IN std_logic;
      t               :  IN std_logic;
      o               :  OUT std_logic);

    ATTRIBUTE Vital_Level0 OF bb : ENTITY IS TRUE;
 
END bb;

-- architecture body --
ARCHITECTURE v OF bb IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL b_ipd  : std_logic := 'X';
   SIGNAL i_ipd  : std_logic := 'X';
   SIGNAL t_ipd  : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (b_ipd, i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS b_zd       : std_ulogic IS results(1);
   ALIAS o_zd       : std_ulogic IS results(2);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE b_GlitchData        : VitalGlitchDataType;
   VARIABLE o_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      b_zd := VitalBUFIF0 (data => i_ipd, enable => tri);
      o_zd := VitalBUF(b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => b,
       OutSignalName => "b",
       OutTemp => b_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_b, TRUE),
                 1 => (t_ipd'last_event, tpd_t_b, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => b_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (b_ipd'last_event, tpd_b_o, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell bbpd -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY bbpd IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "bbpd";
      tpd_i_b         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_b         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_b_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      b               :	INOUT std_logic;
      i               :	IN std_logic;
      t               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF bbpd : ENTITY IS TRUE;
 
END bbpd;

-- architecture body --
ARCHITECTURE v OF bbpd IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (b_ipd, i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE b_ipd2  : std_ulogic := 'X';
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS b_zd       : std_ulogic IS results(1);
   ALIAS o_zd       : std_ulogic IS results(2);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE b_GlitchData	: VitalGlitchDataType;
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      b_ipd2 := VitalIDENT (data => b_ipd,
                           resultmap => ('U','X','0','1','L'));
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      b_zd := VitalBUFIF0 (data => i_ipd, enable => tri, 
                          resultmap => ('U','X','0','1','L'));
      o_zd := VitalBUF(b_ipd2);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => b,
       OutSignalName => "b",
       OutTemp => b_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_b, TRUE),
                 1 => (t_ipd'last_event, tpd_t_b, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => b_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (b_ipd'last_event, tpd_b_o, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell bbpu -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY bbpu IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "bbpu";
      tpd_i_b         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_b         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_b_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      b               :	INOUT std_logic;
      i               :	IN std_logic;
      t               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF bbpu : ENTITY IS TRUE;
 
END bbpu;

-- architecture body --
ARCHITECTURE v OF bbpu IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (b_ipd, i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE b_ipd2  : std_ulogic := 'X';
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS b_zd       : std_ulogic IS results(1);
   ALIAS o_zd       : std_ulogic IS results(2);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE b_GlitchData	: VitalGlitchDataType;
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      b_ipd2 := VitalIDENT (data => b_ipd,
                           resultmap => ('U','X','0','1','H'));
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      b_zd := VitalBUFIF0 (data => i_ipd, enable => tri,
                         resultmap => ('U','X','0','1','H'));
      o_zd := VitalBUF(b_ipd2);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => b,
       OutSignalName => "b",
       OutTemp => b_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_b, TRUE),
                 1 => (t_ipd'last_event, tpd_t_b, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => b_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (b_ipd'last_event, tpd_b_o, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell bbw -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY bbw IS
   GENERIC(
      Keepermode      : boolean := FALSE;
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "bbw";
      tpd_i_b         :  VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_b         :  VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_b_o         :  VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_b          :  VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :  VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :  VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      b               :  INOUT std_logic;
      i               :  IN std_logic;
      t               :  IN std_logic;
      o               :  OUT std_logic);

    ATTRIBUTE Vital_Level0 OF bbw : ENTITY IS TRUE;

END bbw;

-- architecture body --
ARCHITECTURE v OF bbw IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL b_int  : std_logic := 'L';
   SIGNAL b_ipd  : std_logic := 'X';
   SIGNAL i_ipd  : std_logic := 'X';
   SIGNAL t_ipd  : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   KEEP : PROCESS (b)
   BEGIN
        IF (b'event) THEN
           IF (b = '1') THEN
              b_int <= 'H';
           ELSIF (b = '0') THEN
              b_int <= 'L';
           END IF;
        END IF;
   END PROCESS;

   b <= b_int;

   VitalBehavior : PROCESS (b_ipd, i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS b_zd       : std_ulogic IS results(1);
   ALIAS o_zd       : std_ulogic IS results(2);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE b_GlitchData        : VitalGlitchDataType;
   VARIABLE o_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      b_zd := VitalBUFIF0 (data => i_ipd, enable => tri);
      o_zd := VitalBUF(b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => b,
       OutSignalName => "b",
       OutTemp => b_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_b, TRUE),
                 1 => (t_ipd'last_event, tpd_t_b, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => b_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (b_ipd'last_event, tpd_b_o, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell ib -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;


-- entity declaration --
ENTITY ib IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ib";
      tpd_i_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ib : ENTITY IS TRUE;
 
END ib;

-- architecture body --
ARCHITECTURE v OF ib IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      o_zd := VitalBUF(i_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, (tpd_i_o), TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell ibpd -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;


-- entity declaration --
ENTITY ibpd IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ibpd";
      tpd_i_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ibpd : ENTITY IS TRUE;
 
END ibpd;

-- architecture body --
ARCHITECTURE v OF ibpd IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd)

   -- functionality results
   VARIABLE i_ipd2 : std_ulogic := 'X';
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      i_ipd2 := VitalIDENT (data => i_ipd,
                           resultmap => ('U','X','0','1','L'));
      o_zd := VitalBUF(i_ipd2);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, (tpd_i_o), TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell ibpu -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;


-- entity declaration --
ENTITY ibpu IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ibpu";
      tpd_i_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ibpu : ENTITY IS TRUE;
 
END ibpu;

-- architecture body --
ARCHITECTURE v OF ibpu IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd)

   -- functionality results
   VARIABLE i_ipd2 : std_ulogic := 'X';
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      i_ipd2 := VitalIDENT (data => i_ipd,
                           resultmap => ('U','X','0','1','H'));
      o_zd := VitalBUF(i_ipd2);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, (tpd_i_o), TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell ifs1p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1p3bx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1p3bx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk	        : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge	: VitalDelayType := 0.001 ns;
        tpw_sclk_negedge	: VitalDelayType := 0.001 ns;
        tperiod_pd	        : VitalDelayType := 0.001 ns;
        tpw_pd_posedge		: VitalDelayType := 0.001 ns;
        tpw_pd_negedge		: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1p3bx : ENTITY IS TRUE;

END ifs1p3bx ;
 
-- architecture body --
ARCHITECTURE v OF ifs1p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd: std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  pre  ce   sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '-', '1' ),  -- async. preset 
	( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_posedge, 
            SetupLow => tsetup_d_sclk_noedge_posedge,
            HoldHigh => thold_d_sclk_noedge_posedge, 
            HoldLow => thold_d_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk_noedge_posedge, 
            SetupLow => tsetup_sp_sclk_noedge_posedge,
            HoldHigh => thold_sp_sclk_noedge_posedge, 
            HoldLow => thold_sp_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge,
            PulseWidthLow => tpw_pd_negedge,
            PeriodData => periodcheckinfo_pd, Violation => tviol_pd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);

    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => NOT(set_reset), b => pd_ipd);  

    vitalstatetable (statetable => ff_table,
	    datain => (violation, preset, sp_ipd, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell ifs1p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1p3dx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1p3dx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk    	: VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_cd              : VitalDelayType := 0.001 ns;
        tpw_cd_posedge          : VitalDelayType := 0.001 ns;
        tpw_cd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1p3dx : ENTITY IS TRUE;

END ifs1p3dx ;
 
-- architecture body --
ARCHITECTURE v OF ifs1p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  clr  ce   sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '-', '0' ),  -- async. clear 
	( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear	: std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_posedge, 
            SetupLow => tsetup_d_sclk_noedge_posedge,
            HoldHigh => thold_d_sclk_noedge_posedge, 
            HoldLow => thold_d_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk_noedge_posedge, 
            SetupLow => tsetup_sp_sclk_noedge_posedge,
            HoldHigh => thold_sp_sclk_noedge_posedge, 
            HoldLow => thold_sp_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge,
            PulseWidthLow => tpw_cd_negedge,
            PeriodData => periodcheckinfo_cd, Violation => tviol_cd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => NOT(set_reset), b => cd_ipd);  

    vitalstatetable (statetable => ff_table,
	    datain => (violation, clear, sp_ipd, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell ifs1p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1p3ix IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1p3ix";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_cd_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk            : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_cd              : VitalDelayType := 0.001 ns;
        tpw_cd_posedge          : VitalDelayType := 0.001 ns;
        tpw_cd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        sclk              : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1p3ix : ENTITY IS TRUE;

END ifs1p3ix ;
 
-- architecture body --
ARCHITECTURE v OF ifs1p3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  clr  scl  ce   sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '-', '0' ),  -- async. clear (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '0' ),  -- sync. clear 
	( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
	( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tsviol_cd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_posedge, 
            SetupLow => tsetup_d_sclk_noedge_posedge,
            HoldHigh => thold_d_sclk_noedge_posedge, 
            HoldLow => thold_d_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_cd_sclk_noedge_posedge, 
            SetupLow => tsetup_cd_sclk_noedge_posedge,
            HoldHigh => thold_cd_sclk_noedge_posedge, 
            HoldLow => thold_cd_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_sclk_timingdatash,
            Violation => tsviol_cd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk_noedge_posedge, 
            SetupLow => tsetup_sp_sclk_noedge_posedge,
            HoldHigh => thold_sp_sclk_noedge_posedge, 
            HoldLow => thold_sp_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge,
            PulseWidthLow => tpw_cd_negedge,
            PeriodData => periodcheckinfo_cd, Violation => tviol_cd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, cd_ipd, sp_ipd, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell ifs1p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1p3jx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1p3jx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_pd_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        thold_sp_sclk_noedge_posedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk    	: VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_pd              : VitalDelayType := 0.001 ns;
        tpw_pd_posedge          : VitalDelayType := 0.001 ns;
        tpw_pd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        sclk              : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1p3jx : ENTITY IS TRUE;

END ifs1p3jx ;
 
-- architecture body --
ARCHITECTURE v OF ifs1p3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  pre  spr  ce   sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '-', '1' ),  -- async. preset (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '1' ),  -- sync. preset
	( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
	( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_posedge, 
            SetupLow => tsetup_d_sclk_noedge_posedge,
            HoldHigh => thold_d_sclk_noedge_posedge, 
            HoldLow => thold_d_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_pd_sclk_noedge_posedge, 
            SetupLow => tsetup_pd_sclk_noedge_posedge,
            HoldHigh => thold_pd_sclk_noedge_posedge, 
            HoldLow => thold_pd_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_sclk_timingdatash,
            Violation => tsviol_pd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk_noedge_posedge, 
            SetupLow => tsetup_sp_sclk_noedge_posedge,
            HoldHigh => thold_sp_sclk_noedge_posedge, 
            HoldLow => thold_sp_sclk_noedge_posedge,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge,
            PulseWidthLow => tpw_pd_negedge,
            PeriodData => periodcheckinfo_pd, Violation => tviol_pd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, pd_ipd, sp_ipd, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell ifs1s1b -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1s1b IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1s1b";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk            : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_pd              : VitalDelayType := 0.001 ns;
        tpw_pd_posedge          : VitalDelayType := 0.001 ns;
        tpw_pd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1s1b : ENTITY IS TRUE;

END ifs1s1b ;
 
-- architecture body --
ARCHITECTURE v OF ifs1s1b IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 6) := (
      -- viol  pre  sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '1' ),  -- async. preset 
	( '-', '0', '0', '-', '-', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '0', '1', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '0', '1', 'X', '-', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_negedge, 
            SetupLow => tsetup_d_sclk_noedge_negedge,
            HoldHigh => thold_d_sclk_noedge_negedge, 
            HoldLow => thold_d_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge,
            PulseWidthLow => tpw_pd_negedge,
            PeriodData => periodcheckinfo_pd, Violation => tviol_pd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => NOT(set_reset), b => pd_ipd);  

    vitalstatetable (statetable => latch_table,
	    datain => (violation, preset, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell ifs1s1d -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1s1d IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1s1d";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q	        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk            : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_cd              : VitalDelayType := 0.001 ns;
        tpw_cd_posedge          : VitalDelayType := 0.001 ns;
        tpw_cd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1s1d : ENTITY IS TRUE;

END ifs1s1d ;
 
-- architecture body --
ARCHITECTURE v OF ifs1s1d IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 6) := (
      -- viol  clr  sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '0' ),  -- async. clear 
	( '-', '0', '0', '-', '-', 'S' ),  -- clock low
	( '-', '0', '1', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '0', '1', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '0', '1', 'X', '-', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_negedge, 
            SetupLow => tsetup_d_sclk_noedge_negedge,
            HoldHigh => thold_d_sclk_noedge_negedge, 
            HoldLow => thold_d_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge,
            PulseWidthLow => tpw_cd_negedge,
            PeriodData => periodcheckinfo_cd, Violation => tviol_cd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => NOT(set_reset), b => cd_ipd);  

    vitalstatetable (statetable => latch_table,
	    datain => (violation, clear, sclk_ipd, d_ipd),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell ifs1s1i -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1s1i IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1s1i";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q 	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_cd_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_cd_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk            : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_cd              : VitalDelayType := 0.001 ns;
        tpw_cd_posedge          : VitalDelayType := 0.001 ns;
        tpw_cd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1s1i : ENTITY IS TRUE;

END ifs1s1i ;
 
-- architecture body --
ARCHITECTURE v OF ifs1s1i IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL cd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, cd_ipd, sclk_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 6) := (
      -- viol  clr  sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '0' ),  -- async. clear (active low)
        ( '-', '1', '0', '-', '-', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '1', '1', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '1', '1', 'X', '-', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_sclk   : X01 := '0';
   VARIABLE tviol_d      : X01 := '0';
   VARIABLE tviol_cd     : X01 := '0';
   VARIABLE tsviol_cd    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_cd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_negedge, 
            SetupLow => tsetup_d_sclk_noedge_negedge,
            HoldHigh => thold_d_sclk_noedge_negedge, 
            HoldLow => thold_d_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_cd_sclk_noedge_negedge, 
            SetupLow => tsetup_cd_sclk_noedge_negedge,
            HoldHigh => thold_cd_sclk_noedge_negedge, 
            HoldLow => thold_cd_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_sclk_timingdatash,
            Violation => tsviol_cd, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            Period => tperiod_cd,
            PulseWidthHigh => tpw_cd_posedge,
            PulseWidthLow => tpw_cd_negedge,
            PeriodData => periodcheckinfo_cd, Violation => tviol_cd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synclr := VitalAND2 (a => d_ipd, b => NOT(cd_ipd));  

    vitalstatetable (statetable => latch_table,
	    datain => (violation, set_reset, sclk_ipd, synclr),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- cell ifs1s1j -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ifs1s1j IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn	: boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath	: string := "ifs1s1j";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_d_q	        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_d_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        tsetup_pd_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        thold_pd_sclk_noedge_negedge	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk            : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge        : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge        : VitalDelayType := 0.001 ns;
        tperiod_pd              : VitalDelayType := 0.001 ns;
        tpw_pd_posedge          : VitalDelayType := 0.001 ns;
        tpw_pd_negedge          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ifs1s1j : ENTITY IS TRUE;

END ifs1s1j ;
 
-- architecture body --
ARCHITECTURE v OF ifs1s1j IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL pd_ipd  : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, pd_ipd, sclk_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 6, 1 to 6) := (
      -- viol  pre  sclk    d    q  qnew 
	( 'X', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '1' ),  -- async. preset (active low)
        ( '-', '1', '0', '-', '-', 'S' ),  -- clock low
	( '-', '1', '1', '0', '-', '0' ),  -- low d->q on rising edge sclk
	( '-', '1', '1', '1', '-', '1' ),  -- high d->q on rising edge sclk
	( '-', '1', '1', 'X', '-', 'X' ) );  -- clock an x if d is x
	
   -- timing check results 
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tsviol_pd   : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_pd   : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre 	: std_logic := 'X';
   VARIABLE tpd_gsr_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_d_sclk_noedge_negedge, 
            SetupLow => tsetup_d_sclk_noedge_negedge,
            HoldHigh => thold_d_sclk_noedge_negedge, 
            HoldLow => thold_d_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_pd_sclk_noedge_negedge, 
            SetupLow => tsetup_pd_sclk_noedge_negedge,
            HoldHigh => thold_pd_sclk_noedge_negedge, 
            HoldLow => thold_pd_sclk_noedge_negedge,
            CheckEnabled => (set_reset='1'), RefTransition => '\',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_sclk_timingdatash,
            Violation => tsviol_pd, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk_posedge, 
	    PulseWidthLow => tpw_sclk_negedge, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            Period => tperiod_pd,
            PulseWidthHigh => tpw_pd_posedge,
            PulseWidthLow => tpw_pd_negedge,
            PeriodData => periodcheckinfo_pd, Violation => tviol_pd,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    synpre := VitalOR2 (a => d_ipd, b => pd_ipd);  

    vitalstatetable (statetable => latch_table,
	    datain => (violation, set_reset, sclk_ipd, synpre),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (d_ipd'last_event, tpd_d_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3bx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3bx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic; 
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3bx : ENTITY IS TRUE;

END ilf2p3bx ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL pd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock low
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on rising edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on rising edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  pre  ce   clk    d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '-', '1' ),  -- async. preset 
	( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck

	( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "1";
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_eclk or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => NOT(set_reset), b => pd_ipd);  

    vitalstatetable (statetable => latch_table,
            datain => (violation, eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    vitalstatetable (statetable => ff_table,
	    datain => (violation, preset, sp_ipd, sclk_ipd, latched(1)),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3dx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3dx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3dx : ENTITY IS TRUE;

END ilf2p3dx ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL cd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock high
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on falling edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on falling edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  clr  ce   clk   d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '1', '-', '-', '-', '-', '0' ),  -- async. clear 
	( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck
	( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "0";
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE clear       : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'), 
            RefTransition => '\', MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_eclk or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => NOT(set_reset), b => cd_ipd);  

    vitalstatetable (statetable => latch_table,
            datain => (violation, eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    vitalstatetable (statetable => ff_table,
	    datain => (violation, clear, sp_ipd, sclk_ipd, latched(1)),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
		3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3ix IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3ix";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_cd_sclk  : VitalDelayType := 0.0 ns;
        thold_sclk_cd   : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3ix : ENTITY IS TRUE;

END ilf2p3ix ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL cd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock high
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on falling edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on falling edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  clr  scl  ce   clk   d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '-', '0' ),  -- async. clear (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '0' ),  -- sync. clear
	( '-', '1', '-', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '1', '-', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '1', '-', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "0";
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_cd_sclk, SetupLow => tsetup_cd_sclk,
            HoldHigh => thold_sclk_cd, HoldLow => thold_sclk_cd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_sclk_timingdatash,
            Violation => tviol_cd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sp or tviol_eclk or tviol_sclk;
 
    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;

    vitalstatetable (statetable => latch_table,
            datain => (violation, eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, cd_ipd, sp_ipd, sclk_ipd, latched(1)),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3iz -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3iz IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3iz";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_cd_sclk  : VitalDelayType := 0.0 ns;
        thold_sclk_cd   : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        cd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3iz : ENTITY IS TRUE;

END ilf2p3iz ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3iz IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL cd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock high
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on faling edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on faling edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x

   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  clr  ce   clk   d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '0' ),  -- async. clear (active low)
	( '-', '1', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '1', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '1', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "0";
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synclr1     : std_logic := 'X';
   VARIABLE synclr2     : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_cd_sclk, SetupLow => tsetup_cd_sclk,
            HoldHigh => thold_sclk_cd, HoldLow => thold_sclk_cd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_sclk_timingdatash,
            Violation => tviol_cd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sp or tviol_eclk or tviol_sclk;
 
    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;

    vitalstatetable (statetable => latch_table,
            datain => (violation,  eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    synclr2 := VitalAND2 (a => latched(1), b => NOT(cd_ipd));

    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, sp_ipd, sclk_ipd, synclr2),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3jx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3jx";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_pd_sclk  : VitalDelayType := 0.0 ns;
        thold_sclk_pd   : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3jx : ENTITY IS TRUE;

END ilf2p3jx ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL pd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock high
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on falling edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on falling edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x

   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  pre  spr  ce   clk   d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '-', '1' ),  -- async. preset (active low)
	( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '-', '/', '-', '-', '1' ),  -- sync. preset
	( '-', '1', '-', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '1', '-', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '1', '-', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "1";
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_pd_sclk, SetupLow => tsetup_pd_sclk,
            HoldHigh => thold_sclk_pd, HoldLow => thold_sclk_pd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_sclk_timingdatash,
            Violation => tviol_pd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sp or tviol_eclk or tviol_sclk;
 
    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;

    vitalstatetable (statetable => latch_table,
            datain => (violation,  eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, pd_ipd, sp_ipd, sclk_ipd, latched(1)),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;


--
----- ilf2p3jz -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ilf2p3jz IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath	: string := "ilf2p3jz";
        -- propagation delays
        tpd_sclk_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q	: VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk	: VitalDelayType := 0.0 ns;
        thold_eclk_d	: VitalDelayType := 0.0 ns;
        tsetup_pd_sclk  : VitalDelayType := 0.0 ns;
        thold_sclk_pd   : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk	: VitalDelayType := 0.0 ns;
        thold_sclk_sp	: VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp		: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk	: VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk	: VitalDelayType := 0.001 ns;
        tpw_eclk	: VitalDelayType := 0.001 ns;
        tperiod_sclk	: VitalDelayType := 0.001 ns;
        tpw_sclk	: VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        pd              : IN std_logic;
        q               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilf2p3jz : ENTITY IS TRUE;

END ilf2p3jz ;
 
-- architecture body --
ARCHITECTURE v OF ilf2p3jz IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd    : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL sp_ipd   : std_logic := '0';
    SIGNAL pd_ipd   : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)

   CONSTANT latch_table : VitalStateTableType (1 to 5, 1 to 5) := (
      -- viol   ck    d    q  qnew
        ( 'X',  '-', '-', '-', 'X' ),  -- timing violation
        ( '-',  '1', '-', '-', 'S' ),  -- clock high
        ( '-',  '0', '0', '-', '0' ),  -- low d->q on falling edge ck
        ( '-',  '0', '1', '-', '1' ),  -- high d->q on falling edge ck
        ( '-',  '0', 'X', '-', 'X' ) );  -- clock an x if d is x
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  pre  ce   clk   d    q  qnew 
	( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
	( '-', '0', '-', '-', '-', '-', '1' ),  -- async. preset (active low)
	( '-', '1', '0', '-', '-', '-', 'S' ),  -- clock disabled
	( '-', '1', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge clk
	( '-', '1', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge clk
	( '-', '1', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of ck
	( '-', '1', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
	
   -- timing check results 
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results 
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata1   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE prevdata2   : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE latched     : std_logic_vector (1 to 1) := "1";
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd 		: std_ulogic IS results(1);
   VARIABLE synpre1     : std_logic := 'X';
   VARIABLE synpre2     : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;

 
   BEGIN

   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
	    TestSignal => d_ipd, TestSignalName => "d", 
	    RefSignal => eclk_ipd, RefSignalName => "eclk", 
	    SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1'), RefTransition => '\', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash, 
	    Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_pd_sclk, SetupLow => tsetup_pd_sclk,
            HoldHigh => thold_sclk_pd, HoldLow => thold_sclk_pd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_sclk_timingdatash,
            Violation => tviol_pd, MsgSeverity => warning);
        VitalSetupHoldCheck (
	    TestSignal => sp_ipd, TestSignalName => "sp", 
	    RefSignal => sclk_ipd, RefSignalName => "sclk", 
	    SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/', 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash, 
	    Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => eclk_ipd, TestSignalName => "eclk", 
	    Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk, 
	    PulseWidthLow => tpw_eclk, 
	    PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
        VitalPeriodPulseCheck (
	    TestSignal => sclk_ipd, TestSignalName => "sclk", 
	    Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk, 
	    PulseWidthLow => tpw_sclk, 
	    PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk, 
	    MsgOn => MsgOn, XOn => XOn, 
	    HeaderMsg => InstancePath, CheckEnabled => TRUE, 
	    MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sp or tviol_eclk or tviol_sclk;
 
    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;

    vitalstatetable (statetable => latch_table,
            datain => (violation,  eclk_ipd, d_ipd),
            numstates => 1,
            result => latched,
            previousdatain => prevdata1);

    synpre2 := VitalOR2 (a => latched(1), b => pd_ipd);

    vitalstatetable (statetable => ff_table,
	    datain => (violation, set_reset, sp_ipd, sclk_ipd, synpre2),
	    numstates => 1,
	    result => results,
	    previousdatain => prevdata2);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event, 
	              pathdelay => tpd_sclk_q, 
		      pathcondition => TRUE),
		1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
		2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
		3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;
 
END v;



--
----- cell ob -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY ob IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ob";
      tpd_i_o         :	VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ob : ENTITY IS TRUE;
 
END ob;

-- architecture body --
ARCHITECTURE v OF ob IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd : std_ulogic IS results(1);
   VARIABLE tpd_tsall_o : VitalDelayType01 := (0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      o_zd := VitalBUFIF1 (data => i_ipd, enable => tsallnet);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_o, TRUE),
                 1 => (tsallnet'last_event, tpd_tsall_o, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell obz -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY obz IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "obz";
      tpd_i_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      t               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF obz : ENTITY IS TRUE;
 
END obz;

-- architecture body --
ARCHITECTURE v OF obz IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd       : std_ulogic IS results(1);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      o_zd := VitalBUFIF0 (data => i_ipd, enable => tri);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_o, TRUE),
                 1 => (t_ipd'last_event, tpd_t_o, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell obzpd -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY obzpd IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "obzpd";
      tpd_i_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      t               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF obzpd : ENTITY IS TRUE;
 
END obzpd;

-- architecture body --
ARCHITECTURE v OF obzpd IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd       : std_ulogic IS results(1);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      o_zd := VitalBUFIF0 (data => i_ipd, enable => tri,
                         resultmap => ('U','X','0','1','L'));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_o, TRUE),
                 1 => (t_ipd'last_event, tpd_t_o, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell obzpu -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY obzpu IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "obzpu";
      tpd_i_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_o         :	VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               :	IN std_logic;
      t               :	IN std_logic;
      o               :	OUT std_logic);

    ATTRIBUTE Vital_Level0 OF obzpu : ENTITY IS TRUE;
 
END obzpu;

-- architecture body --
ARCHITECTURE v OF obzpu IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (i_ipd, t_ipd, tsallnet)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd       : std_ulogic IS results(1);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z := 
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      o_zd := VitalBUFIF0 (data => i_ipd, enable => tri,
                         resultmap => ('U','X','0','1','H'));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_o, TRUE),
                 1 => (t_ipd'last_event, tpd_t_o, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell obw -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.tsallnet;


-- entity declaration --
ENTITY obw IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "obw";
      tpd_i_o         : VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tpd_t_o         : VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);
      tipd_i          : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      i               : IN std_logic;
      t               : IN std_logic;
      o               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF obw : ENTITY IS TRUE;

END obw;

-- architecture body --
ARCHITECTURE v OF obw IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL o_int  : std_logic := 'X';
   SIGNAL b_int  : std_logic := 'L';
   SIGNAL i_ipd  : std_logic := 'X';
   SIGNAL t_ipd  : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (t_ipd, t, tipd_t);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------

   KEEP : PROCESS (o_int)
   BEGIN
        IF (o_int'event) THEN
           IF (o_int = '1') THEN
              b_int <= 'H';
           ELSIF (o_int = '0') THEN
              b_int <= 'L';
           END IF;
        END IF;
   END PROCESS;

   o_int <= b_int;

   VitalBehavior : PROCESS (i_ipd, t_ipd, tsallnet, o_int)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS o_zd       : std_ulogic IS results(1);
   VARIABLE tri     : std_logic := 'X';
   VARIABLE tpd_tsall_b : VitalDelayType01z :=
               (0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns, 0.001 ns);

   -- output glitch detection VARIABLEs
   VARIABLE o_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      tri := VitalOR2 (a => NOT(tsallnet), b => t_ipd);
      o_int <= VitalBUFIF0 (data => i_ipd, enable => tri);
      o_zd := o_int;

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01z (
       OutSignal => o,
       OutSignalName => "o",
       OutTemp => o_zd,
       Paths => (0 => (i_ipd'last_event, tpd_i_o, TRUE),
                 1 => (t_ipd'last_event, tpd_t_o, TRUE),
                 2 => (tsallnet'last_event, tpd_tsall_b, TRUE)),
       GlitchData => o_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;

--
-----cell ofs1p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofs1p3bx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofs1p3bx";
        -- propagation delays
        tpd_sclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk     : VitalDelayType := 0.0 ns;
        thold_sclk_d      : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk      : VitalDelayType := 0.001 ns;
        tpw_sclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        sclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofs1p3bx : ENTITY IS TRUE;
 
END ofs1p3bx ;
 
-- architecture body --
ARCHITECTURE v OF ofs1p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL pd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  pre  ce   sclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '1', '-', '-', '-', '-', '1' ),  -- async. preset
        ( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
        ( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
        ( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d       : X01 := '0';
   VARIABLE tviol_sp      : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
 
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_d_sclk, SetupLow => tsetup_d_sclk,
            HoldHigh => thold_sclk_d, HoldLow => thold_sclk_d,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => sclk_ipd, TestSignalName => "sclk",
            Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk,
            PulseWidthLow => tpw_sclk,
            PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => NOT(set_reset), b => pd_ipd);
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, preset, sp_ipd, sclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event,
                      pathdelay => tpd_sclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
                3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ofs1p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofs1p3dx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofs1p3dx";
        -- propagation delays
        tpd_sclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk     : VitalDelayType := 0.0 ns;
        thold_sclk_d      : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
        -- pulse width constraints
        tperiod_sclk      : VitalDelayType := 0.001 ns;
        tpw_sclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        sclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofs1p3dx : ENTITY IS TRUE;
 
END ofs1p3dx ;
 
-- architecture body --
ARCHITECTURE v OF ofs1p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL cd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  clr  ce   sclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '1', '-', '-', '-', '-', '0' ),  -- async. clear
        ( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
        ( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
        ( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d       : X01 := '0';
   VARIABLE tviol_sp      : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE clear       : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_d_sclk, SetupLow => tsetup_d_sclk,
            HoldHigh => thold_sclk_d, HoldLow => thold_sclk_d,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => sclk_ipd, TestSignalName => "sclk",
            Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk,
            PulseWidthLow => tpw_sclk,
            PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => NOT(set_reset), b => cd_ipd);
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, clear, sp_ipd, sclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event,
                      pathdelay => tpd_sclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
                3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ofs1p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
 
 
ENTITY ofs1p3ix IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofs1p3ix";
        -- propagation delays
        tpd_sclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk     : VitalDelayType := 0.0 ns;
        thold_sclk_d      : VitalDelayType := 0.0 ns;
        tsetup_cd_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_cd     : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk      : VitalDelayType := 0.001 ns;
        tpw_sclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        sclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofs1p3ix : ENTITY IS TRUE;
 
END ofs1p3ix ;
 
-- architecture body --
ARCHITECTURE v OF ofs1p3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL cd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
 
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, cd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  clr  scl  ce   sclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '0', '-', '-', '-', '-', '-', '0' ),  -- async. clear (active low)
        ( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '1', '1', '-', '/', '-', '-', '0' ),  -- sync. clear
        ( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
        ( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
        ( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g.falling) preserve q
 
   -- timing check results
   VARIABLE tviol_sclk    : X01 := '0';
   VARIABLE tviol_d       : X01 := '0';
   VARIABLE tviol_cd      : X01 := '0';
   VARIABLE tviol_sp      : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_d_sclk, SetupLow => tsetup_d_sclk,
            HoldHigh => thold_sclk_d, HoldLow => thold_sclk_d,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_cd_sclk, SetupLow => tsetup_cd_sclk,
            HoldHigh => thold_sclk_cd, HoldLow => thold_sclk_cd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_sclk_timingdatash,
            Violation => tviol_cd, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => sclk_ipd, TestSignalName => "sclk",
            Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk,
            PulseWidthLow => tpw_sclk,
            PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, set_reset, cd_ipd, sp_ipd, sclk_ipd, d_ipd),
            numstates => 1,
            result => results,
 
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event,
                      pathdelay => tpd_sclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
 
--
----- cell ofs1p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofs1p3jx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofs1p3jx";
        -- propagation delays
        tpd_sclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_sclk     : VitalDelayType := 0.0 ns;
        thold_sclk_d      : VitalDelayType := 0.0 ns;
        tsetup_pd_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_pd     : VitalDelayType := 0.0 ns;
        tsetup_sp_sclk    : VitalDelayType := 0.0 ns;
        thold_sclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_sclk      : VitalDelayType := 0.001 ns;
        tpw_sclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        sclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofs1p3jx : ENTITY IS TRUE;
 
END ofs1p3jx ;
 
-- architecture body --
ARCHITECTURE v OF ofs1p3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
 
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL sclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL pd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, sclk_ipd, pd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  pre  spr  ce   sclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '0', '-', '-', '-', '-', '-', '1' ),  -- async. preset (active low)
        ( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '1', '1', '-', '/', '-', '-', '1' ),  -- sync. preset
        ( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge sclk
        ( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge sclk
        ( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of sclk
        ( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_sclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_sclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_sclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_d_sclk, SetupLow => tsetup_d_sclk,
            HoldHigh => thold_sclk_d, HoldLow => thold_sclk_d,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_sclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_pd_sclk, SetupLow => tsetup_pd_sclk,
            HoldHigh => thold_sclk_pd, HoldLow => thold_sclk_pd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_sclk_timingdatash,
            Violation => tviol_pd, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => sclk_ipd, RefSignalName => "sclk",
            SetupHigh => tsetup_sp_sclk, SetupLow => tsetup_sp_sclk,
            HoldHigh => thold_sclk_sp, HoldLow => thold_sclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_sclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => sclk_ipd, TestSignalName => "sclk",
            Period => tperiod_sclk,
            PulseWidthHigh => tpw_sclk,
            PulseWidthLow => tpw_sclk,
            PeriodData => periodcheckinfo_sclk, Violation => tviol_sclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
 
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sp or tviol_sclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, set_reset, pd_ipd, sp_ipd, sclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event,
                      pathdelay => tpd_sclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 

--
----- cell ofe1p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofe1p3bx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofe1p3bx";
        -- propagation delays
        tpd_eclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_pd_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk     : VitalDelayType := 0.0 ns;
        thold_eclk_d      : VitalDelayType := 0.0 ns;
        tsetup_sp_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk      : VitalDelayType := 0.001 ns;
        tpw_eclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        eclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofe1p3bx : ENTITY IS TRUE;
 
END ofe1p3bx ;
 
-- architecture body --
ARCHITECTURE v OF ofe1p3bx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0'; 
    SIGNAL eclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL pd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, pd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  pre  ce   eclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '1', '-', '-', '-', '-', '1' ),  -- async. preset
        ( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge eclk
        ( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge eclk
        ( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of eclk
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_eclk    : X01 := '0';
   VARIABLE tviol_d       : X01 := '0';
   VARIABLE tviol_sp      : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE preset      : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
 
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_sp_eclk, SetupLow => tsetup_sp_eclk,
            HoldHigh => thold_eclk_sp, HoldLow => thold_eclk_sp,
            CheckEnabled => (set_reset='1' AND pd_ipd='0'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_eclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => eclk_ipd, TestSignalName => "eclk",
            Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk,
            PulseWidthLow => tpw_eclk,
            PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_eclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    preset := VitalOR2 (a => NOT(set_reset), b => pd_ipd);
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, preset, sp_ipd, eclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => eclk_ipd'last_event,
                      pathdelay => tpd_eclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (pd_ipd'last_event, tpd_pd_q, TRUE),
                3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ofe1p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofe1p3dx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofe1p3dx";
        -- propagation delays
        tpd_eclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_cd_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk     : VitalDelayType := 0.0 ns;
        thold_eclk_d      : VitalDelayType := 0.0 ns;
        tsetup_sp_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
        -- pulse width constraints
        tperiod_eclk      : VitalDelayType := 0.001 ns;
        tpw_eclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        eclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofe1p3dx : ENTITY IS TRUE;
 
END ofe1p3dx ;
 
-- architecture body --
ARCHITECTURE v OF ofe1p3dx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL eclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL cd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, cd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 8, 1 to 7) := (
      -- viol  clr  ce   eclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '1', '-', '-', '-', '-', '0' ),  -- async. clear
        ( '-', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge eclk
        ( '-', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge eclk
        ( '-', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of eclk 
        ( '-', '0', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE sp_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE clear       : std_logic := 'X';
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_sp_eclk, SetupLow => tsetup_sp_eclk,
            HoldHigh => thold_eclk_sp, HoldLow => thold_eclk_sp,
            CheckEnabled => (set_reset='1' AND cd_ipd='0'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_eclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => eclk_ipd, TestSignalName => "eclk",
            Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk,
            PulseWidthLow => tpw_eclk,
            PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_sp or tviol_eclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    clear := VitalOR2 (a => NOT(set_reset), b => cd_ipd);
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, clear, sp_ipd, eclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => eclk_ipd'last_event,
                      pathdelay => tpd_eclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (cd_ipd'last_event, tpd_cd_q, TRUE),
                3 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                4 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ofe1p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
 
 
ENTITY ofe1p3ix IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofe1p3ix";
        -- propagation delays
        tpd_eclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk     : VitalDelayType := 0.0 ns;
        thold_eclk_d      : VitalDelayType := 0.0 ns;
        tsetup_cd_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_cd     : VitalDelayType := 0.0 ns;
        tsetup_sp_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_cd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk      : VitalDelayType := 0.001 ns;
        tpw_eclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        cd              : IN std_logic;
        eclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofe1p3ix : ENTITY IS TRUE;
 
END ofe1p3ix ;
 
-- architecture body --
ARCHITECTURE v OF ofe1p3ix IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL eclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL cd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
 
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(cd_ipd, cd, tipd_cd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, cd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  clr  scl  ce   eclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '0', '-', '-', '-', '-', '-', '0' ),  -- async. clear (active low)
        ( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '1', '1', '-', '/', '-', '-', '0' ),  -- sync. clear
        ( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge eclk
        ( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge eclk
        ( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of eclk
        ( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_cd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE cd_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "0";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
 
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND cd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => cd_ipd, TestSignalName => "cd",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_cd_eclk, SetupLow => tsetup_cd_eclk,
            HoldHigh => thold_eclk_cd, HoldLow => thold_eclk_cd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => cd_eclk_timingdatash,
            Violation => tviol_cd, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_sp_eclk, SetupLow => tsetup_sp_eclk,
            HoldHigh => thold_eclk_sp, HoldLow => thold_eclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_eclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => eclk_ipd, TestSignalName => "eclk",
            Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk,
            PulseWidthLow => tpw_eclk,
            PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_cd or tviol_sp or tviol_eclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, set_reset, cd_ipd, sp_ipd, eclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => eclk_ipd'last_event,
                      pathdelay => tpd_eclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ofe1p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.global.gsrnet;
USE work.global.purnet;
 
ENTITY ofe1p3jx IS
    GENERIC (

        gsr             : String := "ENABLED";

        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string := "ofe1p3jx";
        -- propagation delays
        tpd_eclk_q        : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sp_q          : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk     : VitalDelayType := 0.0 ns;
        thold_eclk_d      : VitalDelayType := 0.0 ns;
        tsetup_pd_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_pd     : VitalDelayType := 0.0 ns;
        tsetup_sp_eclk    : VitalDelayType := 0.0 ns;
        thold_eclk_sp     : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d            : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sp           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk         : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_pd           : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk      : VitalDelayType := 0.001 ns;
        tpw_eclk          : VitalDelayType := 0.001 ns);
 
    PORT (
        d               : IN std_logic;
        sp              : IN std_logic;
        pd              : IN std_logic;
        eclk            : IN std_logic;
        q               : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF ofe1p3jx : ENTITY IS TRUE;
 
END ofe1p3jx ;
 
-- architecture body --
ARCHITECTURE v OF ofe1p3jx IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
 
 
    SIGNAL d_ipd     : std_logic := '0';
    SIGNAL eclk_ipd  : std_logic := '0';
    SIGNAL sp_ipd    : std_logic := '0';
    SIGNAL pd_ipd    : std_logic := '0';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(eclk_ipd, eclk , tipd_eclk);
       VitalWireDelay(sp_ipd, sp, tipd_sp);
       VitalWireDelay(pd_ipd, pd, tipd_pd);
    END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d_ipd, sp_ipd, eclk_ipd, pd_ipd, gsrnet, purnet)
 
   CONSTANT ff_table : VitalStateTableType (1 to 9, 1 to 8) := (
      -- viol  pre  spr  ce   eclk  d    q  qnew
        ( 'X', '-', '-', '-', '-', '-', '-', 'X' ),  -- timing violation
        ( '-', '0', '-', '-', '-', '-', '-', '1' ),  -- async. preset (active low)
        ( '-', '1', '0', '0', '-', '-', '-', 'S' ),  -- clock disabled
        ( '-', '1', '1', '-', '/', '-', '-', '1' ),  -- sync. preset
        ( '-', '1', '0', '1', '/', '0', '-', '0' ),  -- low d->q on rising edge eclk
        ( '-', '1', '0', '1', '/', '1', '-', '1' ),  -- high d->q on rising edge eclk
        ( '-', '1', '0', '1', '/', 'X', '-', 'X' ),  -- clock an x if d is x
        ( '-', '1', '0', 'X', '/', '-', '-', 'X' ),  -- ce is x on rising edge of eclk
        ( '-', '1', '-', '-', 'B', '-', '-', 'S' ) );  -- non-x clock (e.g. falling) preserve q
 
   -- timing check results
   VARIABLE tviol_eclk  : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_pd    : X01 := '0';
   VARIABLE tviol_sp    : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE pd_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE sp_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
 
   -- functionality results
   VARIABLE set_reset : std_logic := '1';
   VARIABLE violation   : X01 := '0';
   VARIABLE prevdata    : std_logic_vector (0 to 5) := (others=>'X');
   VARIABLE results     : std_logic_vector (1 to 1) := "1";
   ALIAS q_zd           : std_ulogic IS results(1);
   VARIABLE tpd_gsr_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
   VARIABLE tpd_pur_q   : VitalDelayType01 := (0.001 ns, 0.001 ns);
 
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;
 
 
   BEGIN
 
   ------------------------
   --  timing check section
   ------------------------
 
    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_d_eclk, SetupLow => tsetup_d_eclk,
            HoldHigh => thold_eclk_d, HoldLow => thold_eclk_d,
            CheckEnabled => (set_reset='1' AND pd_ipd='0' AND sp_ipd ='1'),
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => pd_ipd, TestSignalName => "pd",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_pd_eclk, SetupLow => tsetup_pd_eclk,
            HoldHigh => thold_eclk_pd, HoldLow => thold_eclk_pd,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => pd_eclk_timingdatash,
            Violation => tviol_pd, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => sp_ipd, TestSignalName => "sp",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_sp_eclk, SetupLow => tsetup_sp_eclk,
            HoldHigh => thold_eclk_sp, HoldLow => thold_eclk_sp,
            CheckEnabled => (set_reset='1'), RefTransition => '/',
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => sp_eclk_timingdatash,
            Violation => tviol_sp, MsgSeverity => warning);
        VitalPeriodPulseCheck (
            TestSignal => eclk_ipd, TestSignalName => "eclk",
            Period => tperiod_eclk,
            PulseWidthHigh => tpw_eclk,
            PulseWidthLow => tpw_eclk,
            PeriodData => periodcheckinfo_eclk, Violation => tviol_eclk,
            MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, CheckEnabled => TRUE,
            MsgSeverity => warning);
 
    END IF;
 
    -----------------------------------
    -- functionality section.
    -----------------------------------
    violation := tviol_d or tviol_pd or tviol_sp or tviol_eclk;

    IF (gsr = "DISABLED") THEN
       set_reset := purnet;
    ELSE
       set_reset := purnet AND gsrnet;
    END IF;
 
    vitalstatetable (statetable => ff_table,
            datain => (violation, set_reset, pd_ipd, sp_ipd, eclk_ipd, d_ipd),
            numstates => 1,
            result => results,
            previousdatain => prevdata);
 
    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => eclk_ipd'last_event,
                      pathdelay => tpd_eclk_q,
                      pathcondition => TRUE),
                1 => (sp_ipd'last_event, tpd_sp_q, TRUE),
                2 => (gsrnet'last_event, tpd_gsr_q, TRUE),
                3 => (purnet'last_event, tpd_pur_q, TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 
--
----- cell ilvds -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;

-- entity declaration --
ENTITY ilvds IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ilvds";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_an_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_an         : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               : IN std_logic;
      an              : IN std_logic;
      z               : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ilvds : ENTITY IS TRUE;

END ilvds;

-- architecture body --
ARCHITECTURE v OF ilvds IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd   : std_logic := 'X';
   SIGNAL an_ipd  : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (an_ipd, an, tipd_an);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := VitalBUF(a_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, (tpd_a_z), TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell olvds -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;

-- entity declaration --
ENTITY olvds IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "olvds";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a_zn        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               : IN std_logic;
      z               : OUT std_logic;
      zn              : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF olvds : ENTITY IS TRUE;

END olvds;

-- architecture body --
ARCHITECTURE v OF olvds IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd   : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   END BLOCK;

   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS z_zd : std_ulogic IS results(1);
   ALIAS zn_zd : std_ulogic IS results(2);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;
   VARIABLE zn_GlitchData       : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := VitalBUF(a_ipd);
      zn_zd := VitalINV(a_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, (tpd_a_z), TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
      VitalPathDelay01 (
       OutSignal => zn,
       OutSignalName => "zn",
       OutTemp => zn_zd,
       Paths => (0 => (a_ipd'last_event, (tpd_a_zn), TRUE)),
       GlitchData => zn_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_LUT.vhd,v 1.1 2005/12/06 13:00:23 tame Exp $ 
--
----- CELL ORCALUT4 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity ORCALUT4 is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      tpd_A_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_C_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_D_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      INIT                          :	bit_vector);

   port(
      Z                              :	out   STD_ULOGIC;
      A                             :	in    STD_ULOGIC;
      B                             :	in    STD_ULOGIC;
      C                             :	in    STD_ULOGIC;
      D                             :	in    STD_ULOGIC);
attribute VITAL_LEVEL0 of ORCALUT4 : entity is TRUE;
end ORCALUT4;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of ORCALUT4 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B_ipd	 : STD_ULOGIC := 'X';
   SIGNAL C_ipd	 : STD_ULOGIC := 'X';
   SIGNAL D_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A_ipd, A, tipd_A);
   VitalWireDelay (B_ipd, B, tipd_B);
   VitalWireDelay (C_ipd, C, tipd_C);
   VitalWireDelay (D_ipd, D, tipd_D);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A_ipd, B_ipd, C_ipd, D_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   ALIAS Z_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Z_GlitchData	: VitalGlitchDataType;

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      Z_zd := VitalMUX
                 (data => To_StdLogicVector(INIT),
                  dselect => (D_ipd, C_ipd, B_ipd, A_ipd));

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Z,
       GlitchData => Z_GlitchData,
       OutSignalName => "Z",
       OutTemp => Z_zd,
       Paths => (0 => (A_ipd'last_event, tpd_A_Z, TRUE),
                 1 => (B_ipd'last_event, tpd_B_Z, TRUE),
                 2 => (C_ipd'last_event, tpd_C_Z, TRUE),
                 3 => (D_ipd'last_event, tpd_D_Z, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_ORCALUT4_V of ORCALUT4 is
   for V
   end for;
end CFG_ORCALUT4_V;

----- CELL ORCALUT5 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity ORCALUT5 is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      tpd_A_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_C_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_D_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_E_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      INIT                           :	bit_vector);

   port(
      Z                              :	out   STD_ULOGIC;
      A                             :	in    STD_ULOGIC;
      B                             :	in    STD_ULOGIC;
      C                             :	in    STD_ULOGIC;
      D                             :	in    STD_ULOGIC;
      E                             :	in    STD_ULOGIC);
attribute VITAL_LEVEL0 of ORCALUT5 : entity is TRUE;
end ORCALUT5;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of ORCALUT5 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B_ipd	 : STD_ULOGIC := 'X';
   SIGNAL C_ipd	 : STD_ULOGIC := 'X';
   SIGNAL D_ipd	 : STD_ULOGIC := 'X';
   SIGNAL E_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A_ipd, A, tipd_A);
   VitalWireDelay (B_ipd, B, tipd_B);
   VitalWireDelay (C_ipd, C, tipd_C);
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (E_ipd, E, tipd_E);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A_ipd, B_ipd, C_ipd, D_ipd, E_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   ALIAS Z_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Z_GlitchData	: VitalGlitchDataType;

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      Z_zd := VitalMUX
                 (data => To_StdLogicVector(INIT),
                  dselect => (E_ipd, D_ipd, C_ipd, B_ipd, A_ipd));

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Z,
       GlitchData => Z_GlitchData,
       OutSignalName => "Z",
       OutTemp => Z_zd,
       Paths => (0 => (A_ipd'last_event, tpd_A_Z, TRUE),
                 1 => (B_ipd'last_event, tpd_B_Z, TRUE),
                 2 => (C_ipd'last_event, tpd_C_Z, TRUE),
                 3 => (D_ipd'last_event, tpd_D_Z, TRUE),
                 4 => (E_ipd'last_event, tpd_E_Z, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_ORCALUT5_V of ORCALUT5 is
   for V
   end for;
end CFG_ORCALUT5_V;

----- CELL ORCALUT6 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity ORCALUT6 is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      tpd_A_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_C_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_D_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_E_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_F_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_F                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      INIT                           :	bit_vector);

   port(
      Z                              :	out   STD_ULOGIC;
      A                             :	in    STD_ULOGIC;
      B                             :	in    STD_ULOGIC;
      C                             :	in    STD_ULOGIC;
      D                             :	in    STD_ULOGIC;
      E                             :	in    STD_ULOGIC;
      F                             :	in    STD_ULOGIC);
attribute VITAL_LEVEL0 of ORCALUT6 : entity is TRUE;
end ORCALUT6;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of ORCALUT6 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B_ipd	 : STD_ULOGIC := 'X';
   SIGNAL C_ipd	 : STD_ULOGIC := 'X';
   SIGNAL D_ipd	 : STD_ULOGIC := 'X';
   SIGNAL E_ipd	 : STD_ULOGIC := 'X';
   SIGNAL F_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A_ipd, A, tipd_A);
   VitalWireDelay (B_ipd, B, tipd_B);
   VitalWireDelay (C_ipd, C, tipd_C);
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (E_ipd, E, tipd_E);
   VitalWireDelay (F_ipd, F, tipd_F);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A_ipd, B_ipd, C_ipd, D_ipd, E_ipd, F_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   ALIAS Z_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Z_GlitchData	: VitalGlitchDataType;

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      Z_zd := VitalMUX
                 (data => To_StdLogicVector(INIT),
                  dselect => (F_ipd, E_ipd, D_ipd, C_ipd, B_ipd, A_ipd));

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Z,
       GlitchData => Z_GlitchData,
       OutSignalName => "Z",
       OutTemp => Z_zd,
       Paths => (0 => (A_ipd'last_event, tpd_A_Z, TRUE),
                 1 => (B_ipd'last_event, tpd_B_Z, TRUE),
                 2 => (C_ipd'last_event, tpd_C_Z, TRUE),
                 3 => (D_ipd'last_event, tpd_D_Z, TRUE),
                 4 => (E_ipd'last_event, tpd_E_Z, TRUE),
                 5 => (F_ipd'last_event, tpd_F_Z, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_ORCALUT6_V of ORCALUT6 is
   for V
   end for;
end CFG_ORCALUT6_V;

----- CELL ORCALUT7 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity ORCALUT7 is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      tpd_A_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_C_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_D_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_E_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_F_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_G_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_F                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_G                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      INIT                           :	bit_vector);

   port(
      Z                              :	out   STD_ULOGIC;
      A                             :	in    STD_ULOGIC;
      B                             :	in    STD_ULOGIC;
      C                             :	in    STD_ULOGIC;
      D                             :	in    STD_ULOGIC;
      E                             :	in    STD_ULOGIC;
      F                             :	in    STD_ULOGIC;
      G                             :	in    STD_ULOGIC);
attribute VITAL_LEVEL0 of ORCALUT7 : entity is TRUE;
end ORCALUT7;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of ORCALUT7 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B_ipd	 : STD_ULOGIC := 'X';
   SIGNAL C_ipd	 : STD_ULOGIC := 'X';
   SIGNAL D_ipd	 : STD_ULOGIC := 'X';
   SIGNAL E_ipd	 : STD_ULOGIC := 'X';
   SIGNAL F_ipd	 : STD_ULOGIC := 'X';
   SIGNAL G_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A_ipd, A, tipd_A);
   VitalWireDelay (B_ipd, B, tipd_B);
   VitalWireDelay (C_ipd, C, tipd_C);
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (E_ipd, E, tipd_E);
   VitalWireDelay (F_ipd, F, tipd_F);
   VitalWireDelay (G_ipd, G, tipd_G);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A_ipd, B_ipd, C_ipd, D_ipd, E_ipd, F_ipd, G_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   ALIAS Z_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Z_GlitchData	: VitalGlitchDataType;

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      Z_zd := VitalMUX
                 (data => To_StdLogicVector(INIT),
                  dselect => (G_ipd, F_ipd, E_ipd, D_ipd, C_ipd, B_ipd, A_ipd));

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Z,
       GlitchData => Z_GlitchData,
       OutSignalName => "Z",
       OutTemp => Z_zd,
       Paths => (0 => (A_ipd'last_event, tpd_A_Z, TRUE),
                 1 => (B_ipd'last_event, tpd_B_Z, TRUE),
                 2 => (C_ipd'last_event, tpd_C_Z, TRUE),
                 3 => (D_ipd'last_event, tpd_D_Z, TRUE),
                 4 => (E_ipd'last_event, tpd_E_Z, TRUE),
                 5 => (F_ipd'last_event, tpd_F_Z, TRUE),
                 6 => (G_ipd'last_event, tpd_G_Z, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_ORCALUT7_V of ORCALUT7 is
   for V
   end for;
end CFG_ORCALUT7_V;

----- CELL ORCALUT8 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity ORCALUT8 is
   generic(
      TimingChecksOn: Boolean := TRUE;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := False;
      tpd_A_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_C_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_D_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_E_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_F_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_G_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_H_Z                       :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_C                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_D                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_E                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_F                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_G                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_H                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      INIT                           :	bit_vector);

   port(
      Z                              :	out   STD_ULOGIC;
      A                             :	in    STD_ULOGIC;
      B                             :	in    STD_ULOGIC;
      C                             :	in    STD_ULOGIC;
      D                             :	in    STD_ULOGIC;
      E                             :	in    STD_ULOGIC;
      F                             :	in    STD_ULOGIC;
      G                             :	in    STD_ULOGIC;
      H                             :	in    STD_ULOGIC);
attribute VITAL_LEVEL0 of ORCALUT8 : entity is TRUE;
end ORCALUT8;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of ORCALUT8 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B_ipd	 : STD_ULOGIC := 'X';
   SIGNAL C_ipd	 : STD_ULOGIC := 'X';
   SIGNAL D_ipd	 : STD_ULOGIC := 'X';
   SIGNAL E_ipd	 : STD_ULOGIC := 'X';
   SIGNAL F_ipd	 : STD_ULOGIC := 'X';
   SIGNAL G_ipd	 : STD_ULOGIC := 'X';
   SIGNAL H_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A_ipd, A, tipd_A);
   VitalWireDelay (B_ipd, B, tipd_B);
   VitalWireDelay (C_ipd, C, tipd_C);
   VitalWireDelay (D_ipd, D, tipd_D);
   VitalWireDelay (E_ipd, E, tipd_E);
   VitalWireDelay (F_ipd, F, tipd_F);
   VitalWireDelay (G_ipd, G, tipd_G);
   VitalWireDelay (H_ipd, H, tipd_H);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A_ipd, B_ipd, C_ipd, D_ipd, E_ipd, F_ipd, G_ipd, H_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 1) := (others => 'X');
   ALIAS Z_zd : STD_LOGIC is Results(1);

   -- output glitch detection variables
   VARIABLE Z_GlitchData	: VitalGlitchDataType;

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      Z_zd := VitalMUX
                 (data => To_StdLogicVector(INIT),
                  dselect => (H_ipd, G_ipd, F_ipd, E_ipd, D_ipd, C_ipd, B_ipd, A_ipd));

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => Z,
       GlitchData => Z_GlitchData,
       OutSignalName => "Z",
       OutTemp => Z_zd,
       Paths => (0 => (A_ipd'last_event, tpd_A_Z, TRUE),
                 1 => (B_ipd'last_event, tpd_B_Z, TRUE),
                 2 => (C_ipd'last_event, tpd_C_Z, TRUE),
                 3 => (D_ipd'last_event, tpd_D_Z, TRUE),
                 4 => (E_ipd'last_event, tpd_E_Z, TRUE),
                 5 => (F_ipd'last_event, tpd_F_Z, TRUE),
                 6 => (G_ipd'last_event, tpd_G_Z, TRUE),
                 7 => (H_ipd'last_event, tpd_H_Z, TRUE)),
       Mode => OnEvent,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_ORCALUT8_V of ORCALUT8 is
   for V
   end for;
end CFG_ORCALUT8_V;
-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_CMB.vhd,v 1.1 2005/12/06 13:00:23 tame Exp $ 
--

--
----- cell ageb2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY ageb2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "ageb4";
      tpd_a0_ge       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_ge       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_ge       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_ge       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_ge       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_ci         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0              :	IN    std_logic;
      a1              :	IN    std_logic;
      b0              :	IN    std_logic;
      b1              :	IN    std_logic;
      ci              :	IN    std_logic := '1';
      ge              :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF ageb2 : ENTITY IS TRUE;

END ageb2;

-- architecture body --
LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF ageb2 IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a0_ipd	 : std_logic := 'X';
   SIGNAL a1_ipd	 : std_logic := 'X';
   SIGNAL b0_ipd	 : std_logic := 'X';
   SIGNAL b1_ipd	 : std_logic := 'X';
   SIGNAL ci_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (ci_ipd, ci, tipd_ci);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, b1_ipd, ci_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS ge_zd      : std_ulogic IS results(1);
   VARIABLE a, b    : std_logic_vector(0 to 1) := (others => 'X');

   -- output glitch detection VARIABLEs
   VARIABLE ge_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------

      a := std_logic_vector'(a1_ipd, a0_ipd);
      b := std_logic_vector'(b1_ipd, b0_ipd);

      -- if a = b, then output carry-in (ge from the lower stage)
      -- note: carry-in on the first stage is tied high
      IF (a > b) THEN
	ge_zd := '1'; 
      ELSIF (a = b) THEN
	ge_zd := ci_ipd;
      ELSE
	ge_zd := '0';
      END IF;

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => ge,
       OutSignalName => "ge",
       OutTemp => ge_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_ge, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_ge, TRUE),
		 2 => (b0_ipd'last_event, tpd_b0_ge, TRUE),
		 3 => (b1_ipd'last_event, tpd_b1_ge, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_ge, TRUE)),
       GlitchData => ge_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--
----- cell aleb2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY aleb2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "aleb4";
      tpd_a0_le       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_le       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_le       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_le       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_le       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_ci         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0, a1   : IN std_logic;
      b0, b1   : IN std_logic;
      ci       : IN std_logic := '1';
      le       : OUT std_logic);

   ATTRIBUTE Vital_Level0 OF aleb2 : ENTITY IS TRUE;

END aleb2;

-- architecture body --
LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF aleb2 IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a0_ipd	 : std_logic := 'X';
   SIGNAL a1_ipd	 : std_logic := 'X';
   SIGNAL b0_ipd	 : std_logic := 'X';
   SIGNAL b1_ipd	 : std_logic := 'X';
   SIGNAL ci_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (ci_ipd, ci, tipd_ci);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, b1_ipd, ci_ipd) 
   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS le_zd      : std_ulogic IS results(1);
   VARIABLE a, b    : std_logic_vector(0 to 1) := (others => 'X');

   -- output glitch detection VARIABLEs
   VARIABLE le_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------

      a := std_logic_vector'(a1_ipd, a0_ipd);
      b := std_logic_vector'(b1_ipd, b0_ipd);

      -- if a = b, then output carry-in (le from the lower stage)
      -- note: carry-in on the first stage is tied high
      IF (a < b) THEN
	le_zd := '1'; 
      ELSIF (a = b) THEN
	le_zd := ci_ipd;
      ELSE
	le_zd := '0';
      END IF;

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => le,
       OutSignalName => "le",
       OutTemp => le_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_le, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_le, TRUE),
		 2 => (b0_ipd'last_event, tpd_b0_le, TRUE),
		 3 => (b1_ipd'last_event, tpd_b1_le, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_le, TRUE)),
       GlitchData => le_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell aneb2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY aneb2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "aneb4";
      tpd_a0_ne       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_ne       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_ne       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_ne       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_ne       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_ci         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0              :	IN    std_logic;
      a1              :	IN    std_logic;
      b0              :	IN    std_logic;
      b1              :	IN    std_logic;
      ci              :	IN    std_logic := '0';
      ne              :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF aneb2 : ENTITY IS TRUE;

END aneb2;

-- architecture body --
LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF aneb2 IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a0_ipd	 : std_logic := 'X';
   SIGNAL a1_ipd	 : std_logic := 'X';
   SIGNAL b0_ipd	 : std_logic := 'X';
   SIGNAL b1_ipd	 : std_logic := 'X';
   SIGNAL ci_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (ci_ipd, ci, tipd_ci);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, b1_ipd, ci_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS ne_zd      : std_ulogic IS results(1);
   VARIABLE a, b    : std_logic_vector(0 to 1) := (others => 'X');

   -- output glitch detection VARIABLEs
   VARIABLE ne_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------

      a := std_logic_vector'(a1_ipd, a0_ipd);
      b := std_logic_vector'(b1_ipd, b0_ipd);

      -- IF a = b, THEN pass on carry-in input (ne from the previous stage)
      -- note: carry-in on the first stage is tied low
      IF (a = b) THEN
	ne_zd := ci_ipd; 
      ELSE
	ne_zd := '1';
      END IF;

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => ne,
       OutSignalName => "ne",
       OutTemp => ne_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_ne, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_ne, TRUE),
		 2 => (b0_ipd'last_event, tpd_b0_ne, TRUE),
		 3 => (b1_ipd'last_event, tpd_b1_ne, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_ne, TRUE)),
       GlitchData => ne_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell and2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY and2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "and2";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF and2 : ENTITY IS TRUE;

END and2;

-- architecture body --
LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF and2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd AND b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell and3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY and3 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "and3";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT   std_logic); 

   ATTRIBUTE Vital_Level0 OF and3 : ENTITY IS TRUE;

END and3;

-- architecture body --
LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF and3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd AND b_ipd AND c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell and4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY and4 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "and4";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF and4 : ENTITY IS TRUE;

END and4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF and4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd AND b_ipd AND c_ipd AND d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell and5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY and5 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "and5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF and5 : ENTITY IS TRUE;

END and5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF and5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd AND b_ipd AND c_ipd AND d_ipd AND e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;



--
----- cell fadd2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY fadd2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "fadd2";
      tpd_a0_cout0    :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_cout0    :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_cout0    :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_cout0    :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_cout0    :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_cout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_cout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_cout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_cout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_cout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_s0       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_s1       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_s0       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_s1       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_s0       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_s1       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_s0       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_s1       :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_ci_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_ci         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0              :	IN    std_logic;
      a1              :	IN    std_logic;
      b0              :	IN    std_logic;
      b1              :	IN    std_logic;
      ci              :	IN    std_logic;
      s0              :	OUT   std_logic;
      s1              :	OUT   std_logic;
      cout0           :	OUT   std_logic;
      cout1           :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF fadd2 : ENTITY IS TRUE;

END fadd2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF fadd2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL a0_ipd : std_logic := 'X';
   SIGNAL a1_ipd : std_logic := 'X';
   SIGNAL b0_ipd : std_logic := 'X';
   SIGNAL b1_ipd : std_logic := 'X';
   SIGNAL ci_ipd : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (ci_ipd, ci, tipd_ci);
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, 
			    b1_ipd, ci_ipd)
 
   -- functionality results
   VARIABLE results1 : std_logic_vector(1 to 2) := (others => 'X');
   VARIABLE results2 : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS cout0_zd      : std_ulogic IS results1(1);
   ALIAS s0_zd      : std_ulogic IS results1(2);
   ALIAS cout1_zd      : std_ulogic IS results2(1);
   ALIAS s1_zd      : std_ulogic IS results2(2);
 
   -- output glitch detection VARIABLEs
   VARIABLE cout0_GlitchData    : VitalGlitchDataType;
   VARIABLE s0_GlitchData    : VitalGlitchDataType;
   VARIABLE cout1_GlitchData    : VitalGlitchDataType;
   VARIABLE s1_GlitchData    : VitalGlitchDataType;
 
   constant add_table : vitaltruthtabletype := (
   --------------------------------------------
   --  a    b    ci   |   co   s
   --------------------------------------------
    ( '0', '0', '0',     '0', '0'),
    ( '1', '0', '0',     '0', '1'),
    ( '0', '1', '0',     '0', '1'),
    ( '1', '1', '0',     '1', '0'),
    ( '0', '0', '1',     '0', '1'),
    ( '1', '0', '1',     '1', '0'),
    ( '0', '1', '1',     '1', '0'),
    ( '1', '1', '1',     '1', '1'));
 
   BEGIN
 
      -------------------------
      --  functionality section
      -------------------------
      results1 := vitaltruthtable (
                truthtable => add_table,
                datain => (a0_ipd, b0_ipd, ci_ipd)
                );
      results2 := vitaltruthtable (
                truthtable => add_table,
                datain => (a1_ipd, b1_ipd, cout0_zd)
                );

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => cout0,
       OutSignalName => "cout0",
       OutTemp => cout0_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_cout0, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_cout0, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_cout0, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_cout0, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_cout0, TRUE)),
       GlitchData => cout0_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
      VitalPathDelay01 (
       OutSignal => s0,
       OutSignalName => "s0",
       OutTemp => s0_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s0, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s0, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s0, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s0, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_s0, TRUE)),
       GlitchData => s0_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => s1,
       OutSignalName => "s1",
       OutTemp => s1_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s1, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s1, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s1, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s1, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_s1, TRUE)),
       GlitchData => s1_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
      VitalPathDelay01 (
       OutSignal => cout1,
       OutSignalName => "cout1",
       OutTemp => cout1_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_cout1, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_cout1, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_cout1, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_cout1, TRUE),
		 4 => (ci_ipd'last_event, tpd_ci_cout1, TRUE)),
       GlitchData => cout1_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;


--
----- cell fsub2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY fsub2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "fsub2";
      tpd_a0_bout0    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_bout0    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_bout0    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_bout0    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_bi_bout0    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_bout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_bout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_bout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_bout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_bi_bout1    : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_bi_s0       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a0_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_a1_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b0_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b1_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_bi_s1       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_bi         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0                     :	IN    std_logic;
      a1                     :	IN    std_logic;
      b0                     :	IN    std_logic;
      b1                     :	IN    std_logic;
      bi                     :	IN    std_logic;
      bout0                  :	OUT   std_logic;
      bout1                  :	OUT   std_logic;
      s0                     :	OUT   std_logic;
      s1                     :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF fsub2 : ENTITY IS TRUE;

END fsub2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF fsub2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL a0_ipd         : std_logic := 'X';
   SIGNAL a1_ipd         : std_logic := 'X';
   SIGNAL b0_ipd         : std_logic := 'X';
   SIGNAL b1_ipd         : std_logic := 'X';
   SIGNAL bi_ipd         : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (bi_ipd, bi, tipd_bi);
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, 
			    b1_ipd, bi_ipd)
 
   -- functionality results
   VARIABLE results1 : std_logic_vector(1 to 2) := (others => 'X');
   VARIABLE results2 : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS bout0_zd      : std_ulogic IS results1(1);
   ALIAS s0_zd      : std_ulogic IS results1(2);
   ALIAS bout1_zd      : std_ulogic IS results2(1);
   ALIAS s1_zd      : std_ulogic IS results2(2);
 
   -- output glitch detection VARIABLEs
   VARIABLE bout0_GlitchData    : VitalGlitchDataType;
   VARIABLE s0_GlitchData    : VitalGlitchDataType;
   VARIABLE bout1_GlitchData    : VitalGlitchDataType;
   VARIABLE s1_GlitchData    : VitalGlitchDataType;

   constant sub_table : vitaltruthtabletype := (
   --------------------------------------------
   --  a    b    bi   |   bo   s
   --------------------------------------------
    ( '0', '0', '0',     '0', '1'),
    ( '1', '0', '0',     '1', '0'),
    ( '0', '1', '0',     '0', '0'),
    ( '1', '1', '0',     '0', '1'),
    ( '0', '0', '1',     '1', '0'),
    ( '1', '0', '1',     '1', '1'),
    ( '0', '1', '1',     '0', '1'),
    ( '1', '1', '1',     '1', '0'));
 
   BEGIN
 
      -------------------------
      --  functionality section
      -------------------------
      results1 := vitaltruthtable (
                truthtable => sub_table,
                datain => (a0_ipd, b0_ipd, bi_ipd)
                );
      results2 := vitaltruthtable (
                truthtable => sub_table,
                datain => (a1_ipd, b1_ipd, bout0_zd)
                );
 
      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => bout0,
       OutSignalName => "bout0",
       OutTemp => bout0_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_bout0, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_bout0, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_bout0, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_bout0, TRUE),
		 4 => (bi_ipd'last_event, tpd_bi_bout0, TRUE)),
       GlitchData => bout0_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
      VitalPathDelay01 (
       OutSignal => s0,
       OutSignalName => "s0",
       OutTemp => s0_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s0, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s0, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s0, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s0, TRUE),
		 4 => (bi_ipd'last_event, tpd_bi_s0, TRUE)),
       GlitchData => s0_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => s1,
       OutSignalName => "s1",
       OutTemp => s1_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s1, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s1, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s1, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s1, TRUE),
		 4 => (bi_ipd'last_event, tpd_bi_s1, TRUE)),
       GlitchData => s1_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => bout1,
       OutSignalName => "bout1",
       OutTemp => bout1_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_bout1, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_bout1, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_bout1, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_bout1, TRUE),
                 4 => (bi_ipd'last_event, tpd_bi_bout1, TRUE)),
       GlitchData => bout1_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
END PROCESS;

END v;



----- cell fadsu2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY fadsu2 IS
   GENERIC(
      TimingChecksOn : boolean := TRUE;
      XOn            : boolean := FALSE;
      MsgOn          : boolean := TRUE;
      InstancePath   : string := "fadsu2";
      tpd_a0_bco     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a1_bco     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b0_bco     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b1_bco     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_bci_bco    : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_con_bco    : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a0_s0      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a0_s1      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a1_s0      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a1_s1      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_a1_s2      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b0_s0      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b0_s1      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b1_s0      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_b1_s1      : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_bci_s0     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_bci_s1     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_con_s0     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_con_s1     : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_a0        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_a1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b0        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_bci       : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_con       : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a0             :	IN    std_logic;
      a1             :	IN    std_logic;
      b0             :	IN    std_logic;
      b1             :	IN    std_logic;
      bci            :	IN    std_logic;
      con            :	IN    std_logic;
      bco            :	OUT   std_logic;
      s0             :	OUT   std_logic;
      s1             :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF fadsu2 : ENTITY IS TRUE;

END fadsu2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF fadsu2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL a0_ipd  : std_logic := 'X';
   SIGNAL a1_ipd  : std_logic := 'X';
   SIGNAL b0_ipd  : std_logic := 'X';
   SIGNAL b1_ipd  : std_logic := 'X';
   SIGNAL bci_ipd : std_logic := 'X';
   SIGNAL con_ipd : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a0_ipd, a0, tipd_a0);
   VitalWireDelay (a1_ipd, a1, tipd_a1);
   VitalWireDelay (b0_ipd, b0, tipd_b0);
   VitalWireDelay (b1_ipd, b1, tipd_b1);
   VitalWireDelay (bci_ipd, bci, tipd_bci);
   VitalWireDelay (con_ipd, con, tipd_con);
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a0_ipd, a1_ipd, b0_ipd, b1_ipd, bci_ipd, con_ipd)
 
   -- functionality results
   VARIABLE results1 : std_logic_vector(1 to 2) := (others => 'X');
   VARIABLE results2 : std_logic_vector(1 to 2) := (others => 'X');
   VARIABLE results3 : std_logic_vector(1 to 2) := (others => 'X');
   VARIABLE results4 : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS bc0_zd     : std_ulogic IS results1(1);
   ALIAS s0_zd      : std_ulogic IS results1(2);
   ALIAS bco_zd     : std_ulogic IS results2(1);
   ALIAS s1_zd      : std_ulogic IS results2(2);

 
   -- output glitch detection VARIABLEs
   VARIABLE bco_GlitchData   : VitalGlitchDataType;
   VARIABLE s0_GlitchData    : VitalGlitchDataType;
   VARIABLE s1_GlitchData    : VitalGlitchDataType;
   constant adsu_table : vitaltruthtabletype := (
   --------------------------------------------
   --   a    b   bci  con  |   bco   s
   --------------------------------------------
      ('0', '0', '0', '1',     '0', '0'),
      ('1', '0', '0', '1',     '0', '1'),
      ('0', '1', '0', '1',     '0', '1'),
      ('1', '1', '0', '1',     '1', '0'),
      ('0', '0', '1', '1',     '0', '1'),
      ('1', '0', '1', '1',     '1', '0'),
      ('0', '1', '1', '1',     '1', '0'),
      ('1', '1', '1', '1',     '1', '1'),
      ('0', '0', '0', '0',     '0', '1'),
      ('1', '0', '0', '0',     '1', '0'),
      ('0', '1', '0', '0',     '0', '0'),
      ('1', '1', '0', '0',     '0', '1'),
      ('0', '0', '1', '0',     '1', '0'),
      ('1', '0', '1', '0',     '1', '1'),
      ('0', '1', '1', '0',     '0', '1'),
      ('1', '1', '1', '0',     '1', '0'));

   BEGIN

      IF (TimingChecksOn) THEN
      -----------------------------------
      -- no timing checks for a comb gate
      -----------------------------------
      END IF;
 
      -------------------------
      --  functionality section
      -------------------------
      results1 := vitaltruthtable (
                truthtable => adsu_table,
                datain => (a0_ipd, b0_ipd, bci_ipd, con_ipd)
                );
      results2 := vitaltruthtable (
                truthtable => adsu_table,
                datain => (a1_ipd, b1_ipd, bc0_zd, con_ipd)
                );

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => bco,
       OutSignalName => "bco",
       OutTemp => bco_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_bco, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_bco, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_bco, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_bco, TRUE),
		 4 => (bci_ipd'last_event, tpd_bci_bco, TRUE),
		 5 => (con_ipd'last_event, tpd_con_bco, TRUE)),
       GlitchData => bco_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
      VitalPathDelay01 (
       OutSignal => s0,
       OutSignalName => "s0",
       OutTemp => s0_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s0, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s0, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s0, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s0, TRUE),
		 4 => (bci_ipd'last_event, tpd_bci_s0, TRUE),
		 5 => (con_ipd'last_event, tpd_con_s0, TRUE)),
       GlitchData => s0_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

      VitalPathDelay01 (
       OutSignal => s1,
       OutSignalName => "s1",
       OutTemp => s1_zd,
       Paths => (0 => (a0_ipd'last_event, tpd_a0_s1, TRUE),
                 1 => (a1_ipd'last_event, tpd_a1_s1, TRUE),
                 2 => (b0_ipd'last_event, tpd_b0_s1, TRUE),
                 3 => (b1_ipd'last_event, tpd_b1_s1, TRUE),
		 4 => (bci_ipd'last_event, tpd_bci_s1, TRUE),
		 5 => (con_ipd'last_event, tpd_con_s1, TRUE)),
       GlitchData => s1_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
 
END PROCESS;

END v;



--
----- cell inv -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY inv IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "inv";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a                              :	IN    std_logic;
      z                              :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF inv : ENTITY IS TRUE;

END inv;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF inv IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (NOT a_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell mux21 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY mux21 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "mux21";
      tpd_d0_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              :	IN    std_logic;
      d1              :	IN    std_logic;
      sd              :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF mux21 : ENTITY IS TRUE;

END mux21;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF mux21 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd	 : std_logic := 'X';
   SIGNAL d1_ipd	 : std_logic := 'X';
   SIGNAL sd_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (sd_ipd, sd, tipd_sd);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (sd_ipd'last_event, tpd_sd_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;



--
----- cell l6mux21 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY l6mux21 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "l6mux21";
      tpd_d0_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              :	IN    std_logic;
      d1              :	IN    std_logic;
      sd              :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF l6mux21 : ENTITY IS TRUE;

END l6mux21;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF l6mux21 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd	 : std_logic := 'X';
   SIGNAL d1_ipd	 : std_logic := 'X';
   SIGNAL sd_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (sd_ipd, sd, tipd_sd);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, sd_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d1_ipd, d0_ipd),
                  dselect => (0 => sd_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (sd_ipd'last_event, tpd_sd_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell mux41 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;

ENTITY mux41 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "mux41";
      tpd_d0_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d2_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d3_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd1_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd2_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d2         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d3         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd2        : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              :	IN    std_logic;
      d1              :	IN    std_logic;
      d2              :	IN    std_logic;
      d3              :	IN    std_logic;
      sd1             :	IN    std_logic;
      sd2             :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF mux41 : ENTITY IS TRUE;

END mux41;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF mux41 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd	 : std_logic := 'X';
   SIGNAL d1_ipd	 : std_logic := 'X';
   SIGNAL d2_ipd	 : std_logic := 'X';
   SIGNAL d3_ipd	 : std_logic := 'X';
   SIGNAL sd1_ipd	 : std_logic := 'X';
   SIGNAL sd2_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (d2_ipd, d2, tipd_d2);
   VitalWireDelay (d3_ipd, d3, tipd_d3);
   VitalWireDelay (sd1_ipd, sd1, tipd_sd1);
   VitalWireDelay (sd2_ipd, sd2, tipd_sd2);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, d2_ipd, d3_ipd, sd1_ipd, sd2_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d3_ipd, d2_ipd, d1_ipd, d0_ipd),
                  dselect => (sd2_ipd, sd1_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
          Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (d2_ipd'last_event, tpd_d2_z, TRUE),
                 3 => (d3_ipd'last_event, tpd_d3_z, TRUE),
		 4 => (sd1_ipd'last_event, tpd_sd1_z, TRUE),
                 5 => (sd2_ipd'last_event, tpd_sd2_z, TRUE)),

       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;



--
----- cell mux81 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY mux81 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "mux81";
      tpd_d0_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d2_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d3_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d4_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d5_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d6_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d7_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd1_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd2_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd3_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d2         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d3         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d4         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d5         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d6         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d7         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd2        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd3        : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              : IN    std_logic;
      d1              : IN    std_logic;
      d2              : IN    std_logic;
      d3              : IN    std_logic;
      d4              : IN    std_logic;
      d5              : IN    std_logic;
      d6              : IN    std_logic;
      d7              : IN    std_logic;
      sd1             : IN    std_logic;
      sd2             : IN    std_logic;
      sd3             : IN    std_logic;
      z               : OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF mux81 : ENTITY IS TRUE;

END mux81;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF mux81 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd         : std_logic := 'X';
   SIGNAL d1_ipd         : std_logic := 'X';
   SIGNAL d2_ipd         : std_logic := 'X';
   SIGNAL d3_ipd         : std_logic := 'X';
   SIGNAL d4_ipd         : std_logic := 'X';
   SIGNAL d5_ipd         : std_logic := 'X';
   SIGNAL d6_ipd         : std_logic := 'X';
   SIGNAL d7_ipd         : std_logic := 'X';
   SIGNAL sd1_ipd        : std_logic := 'X';
   SIGNAL sd2_ipd        : std_logic := 'X';
   SIGNAL sd3_ipd        : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (d2_ipd, d2, tipd_d2);
   VitalWireDelay (d3_ipd, d3, tipd_d3);
   VitalWireDelay (d4_ipd, d4, tipd_d4);
   VitalWireDelay (d5_ipd, d5, tipd_d5);
   VitalWireDelay (d6_ipd, d6, tipd_d6);
   VitalWireDelay (d7_ipd, d7, tipd_d7);
   VitalWireDelay (sd1_ipd, sd1, tipd_sd1);
   VitalWireDelay (sd2_ipd, sd2, tipd_sd2);
   VitalWireDelay (sd3_ipd, sd3, tipd_sd3);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, d2_ipd, d3_ipd, d4_ipd, d5_ipd, d6_ipd, d7_ipd, sd1_ipd, sd2_ipd, sd3_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d7_ipd, d6_ipd, d5_ipd, d4_ipd, d3_ipd, d2_ipd, d1_ipd, d0_ipd),
                  dselect => (sd3_ipd, sd2_ipd, sd1_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
          Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (d2_ipd'last_event, tpd_d2_z, TRUE),
                 3 => (d3_ipd'last_event, tpd_d3_z, TRUE),
                 4 => (d4_ipd'last_event, tpd_d4_z, TRUE),
                 5 => (d5_ipd'last_event, tpd_d5_z, TRUE),
                 6 => (d6_ipd'last_event, tpd_d6_z, TRUE),
                 7 => (d7_ipd'last_event, tpd_d7_z, TRUE),
                 8 => (sd1_ipd'last_event, tpd_sd1_z, TRUE),
                 9 => (sd2_ipd'last_event, tpd_sd2_z, TRUE),
                10 => (sd3_ipd'last_event, tpd_sd3_z, TRUE)),

       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;

--
----- cell mux161 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY mux161 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "mux81";
      tpd_d0_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d2_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d3_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d4_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d5_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d6_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d7_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d8_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d9_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d10_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d11_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d12_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d13_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d14_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d15_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd1_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd2_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd3_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd4_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d2         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d3         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d4         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d5         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d6         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d7         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d8         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d9         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d10        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d11        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d12        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d13        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d14        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d15        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd2        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd3        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd4        : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              : IN    std_logic;
      d1              : IN    std_logic;
      d2              : IN    std_logic;
      d3              : IN    std_logic;
      d4              : IN    std_logic;
      d5              : IN    std_logic;
      d6              : IN    std_logic;
      d7              : IN    std_logic;
      d8              : IN    std_logic;
      d9              : IN    std_logic;
      d10             : IN    std_logic;
      d11             : IN    std_logic;
      d12             : IN    std_logic;
      d13             : IN    std_logic;
      d14             : IN    std_logic;
      d15             : IN    std_logic;
      sd1             : IN    std_logic;
      sd2             : IN    std_logic;
      sd3             : IN    std_logic;
      sd4             : IN    std_logic;
      z               : OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF mux161 : ENTITY IS TRUE;

END mux161;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF mux161 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd         : std_logic := 'X';
   SIGNAL d1_ipd         : std_logic := 'X';
   SIGNAL d2_ipd         : std_logic := 'X';
   SIGNAL d3_ipd         : std_logic := 'X';
   SIGNAL d4_ipd         : std_logic := 'X';
   SIGNAL d5_ipd         : std_logic := 'X';
   SIGNAL d6_ipd         : std_logic := 'X';
   SIGNAL d7_ipd         : std_logic := 'X';
   SIGNAL d8_ipd         : std_logic := 'X';
   SIGNAL d9_ipd         : std_logic := 'X';
   SIGNAL d10_ipd         : std_logic := 'X';
   SIGNAL d11_ipd         : std_logic := 'X';
   SIGNAL d12_ipd         : std_logic := 'X';
   SIGNAL d13_ipd         : std_logic := 'X';
   SIGNAL d14_ipd         : std_logic := 'X';
   SIGNAL d15_ipd         : std_logic := 'X';
   SIGNAL sd1_ipd        : std_logic := 'X';
   SIGNAL sd2_ipd        : std_logic := 'X';
   SIGNAL sd3_ipd        : std_logic := 'X';
   SIGNAL sd4_ipd        : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (d2_ipd, d2, tipd_d2);
   VitalWireDelay (d3_ipd, d3, tipd_d3);
   VitalWireDelay (d4_ipd, d4, tipd_d4);
   VitalWireDelay (d5_ipd, d5, tipd_d5);
   VitalWireDelay (d6_ipd, d6, tipd_d6);
   VitalWireDelay (d7_ipd, d7, tipd_d7);
   VitalWireDelay (d8_ipd, d8, tipd_d8);
   VitalWireDelay (d9_ipd, d9, tipd_d9);
   VitalWireDelay (d10_ipd, d10, tipd_d10);
   VitalWireDelay (d11_ipd, d11, tipd_d11);
   VitalWireDelay (d12_ipd, d12, tipd_d12);
   VitalWireDelay (d13_ipd, d13, tipd_d13);
   VitalWireDelay (d14_ipd, d14, tipd_d14);
   VitalWireDelay (d15_ipd, d15, tipd_d15);
   VitalWireDelay (sd1_ipd, sd1, tipd_sd1);
   VitalWireDelay (sd2_ipd, sd2, tipd_sd2);
   VitalWireDelay (sd3_ipd, sd3, tipd_sd3);
   VitalWireDelay (sd4_ipd, sd4, tipd_sd4);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, d2_ipd, d3_ipd, d4_ipd, d5_ipd, d6_ipd, d7_ipd, d8_ipd, d9_ipd, d10_ipd, d11_ipd, d12_ipd, d13_ipd, d14_ipd, d15_ipd, sd1_ipd, sd2_ipd, sd3_ipd, sd4_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d15_ipd, d14_ipd, d13_ipd, d12_ipd, d11_ipd, d10_ipd, d9_ipd, d8_ipd, d7_ipd, d6_ipd, d5_ipd, d4_ipd, d3_ipd, d2_ipd, d1_ipd, d0_ipd),
                  dselect => (sd4_ipd, sd3_ipd, sd2_ipd, sd1_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
          Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (d2_ipd'last_event, tpd_d2_z, TRUE),
                 3 => (d3_ipd'last_event, tpd_d3_z, TRUE),
                 4 => (d4_ipd'last_event, tpd_d4_z, TRUE),
                 5 => (d5_ipd'last_event, tpd_d5_z, TRUE),
                 6 => (d6_ipd'last_event, tpd_d6_z, TRUE),
                 7 => (d7_ipd'last_event, tpd_d7_z, TRUE),
                 8 => (d8_ipd'last_event, tpd_d8_z, TRUE),
                 9 => (d9_ipd'last_event, tpd_d9_z, TRUE),
                 10 => (d10_ipd'last_event, tpd_d10_z, TRUE),
                 11 => (d11_ipd'last_event, tpd_d11_z, TRUE),
                 12 => (d12_ipd'last_event, tpd_d12_z, TRUE),
                 13 => (d13_ipd'last_event, tpd_d13_z, TRUE),
                 14 => (d14_ipd'last_event, tpd_d14_z, TRUE),
                 15 => (d15_ipd'last_event, tpd_d15_z, TRUE),
                 16 => (sd1_ipd'last_event, tpd_sd1_z, TRUE),
                 17 => (sd2_ipd'last_event, tpd_sd2_z, TRUE),
                 18 => (sd3_ipd'last_event, tpd_sd3_z, TRUE),
                19 => (sd4_ipd'last_event, tpd_sd4_z, TRUE)),

       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell mux321 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY mux321 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "mux81";
      tpd_d0_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d1_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d2_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d3_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d4_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d5_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d6_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d7_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d8_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d9_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d10_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d11_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d12_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d13_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d14_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d15_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d16_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d17_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d18_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d19_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d20_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d21_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d22_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d23_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d24_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d25_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d26_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d27_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d28_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d29_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d30_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d31_z        : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd1_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd2_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd3_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd4_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_sd5_z       : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_d0         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d1         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d2         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d3         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d4         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d5         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d6         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d7         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d8         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d9         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d10        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d11        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d12        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d13        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d14        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d15        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d16        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d17        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d18        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d19        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d20        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d21        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d22        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d23        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d24        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d25        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d26        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d27        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d28        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d29        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d30        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d31        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd1        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd2        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd3        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd4        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sd5        : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      d0              : IN    std_logic;
      d1              : IN    std_logic;
      d2              : IN    std_logic;
      d3              : IN    std_logic;
      d4              : IN    std_logic;
      d5              : IN    std_logic;
      d6              : IN    std_logic;
      d7              : IN    std_logic;
      d8              : IN    std_logic;
      d9              : IN    std_logic;
      d10             : IN    std_logic;
      d11             : IN    std_logic;
      d12             : IN    std_logic;
      d13             : IN    std_logic;
      d14             : IN    std_logic;
      d15             : IN    std_logic;
      d16             : IN    std_logic;
      d17             : IN    std_logic;
      d18             : IN    std_logic;
      d19             : IN    std_logic;
      d20             : IN    std_logic;
      d21             : IN    std_logic;
      d22             : IN    std_logic;
      d23             : IN    std_logic;
      d24             : IN    std_logic;
      d25             : IN    std_logic;
      d26             : IN    std_logic;
      d27             : IN    std_logic;
      d28             : IN    std_logic;
      d29             : IN    std_logic;
      d30             : IN    std_logic;
      d31             : IN    std_logic;
      sd1             : IN    std_logic;
      sd2             : IN    std_logic;
      sd3             : IN    std_logic;
      sd4             : IN    std_logic;
      sd5             : IN    std_logic;
      z               : OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF mux321 : ENTITY IS TRUE;

END mux321;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF mux321 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL d0_ipd         : std_logic := 'X';
   SIGNAL d1_ipd         : std_logic := 'X';
   SIGNAL d2_ipd         : std_logic := 'X';
   SIGNAL d3_ipd         : std_logic := 'X';
   SIGNAL d4_ipd         : std_logic := 'X';
   SIGNAL d5_ipd         : std_logic := 'X';
   SIGNAL d6_ipd         : std_logic := 'X';
   SIGNAL d7_ipd         : std_logic := 'X';
   SIGNAL d8_ipd         : std_logic := 'X';
   SIGNAL d9_ipd         : std_logic := 'X';
   SIGNAL d10_ipd         : std_logic := 'X';
   SIGNAL d11_ipd         : std_logic := 'X';
   SIGNAL d12_ipd         : std_logic := 'X';
   SIGNAL d13_ipd         : std_logic := 'X';
   SIGNAL d14_ipd         : std_logic := 'X';
   SIGNAL d15_ipd         : std_logic := 'X';
   SIGNAL d16_ipd         : std_logic := 'X';
   SIGNAL d17_ipd         : std_logic := 'X';
   SIGNAL d18_ipd         : std_logic := 'X';
   SIGNAL d19_ipd         : std_logic := 'X';
   SIGNAL d20_ipd         : std_logic := 'X';
   SIGNAL d21_ipd         : std_logic := 'X';
   SIGNAL d22_ipd         : std_logic := 'X';
   SIGNAL d23_ipd         : std_logic := 'X';
   SIGNAL d24_ipd         : std_logic := 'X';
   SIGNAL d25_ipd         : std_logic := 'X';
   SIGNAL d26_ipd         : std_logic := 'X';
   SIGNAL d27_ipd         : std_logic := 'X';
   SIGNAL d28_ipd         : std_logic := 'X';
   SIGNAL d29_ipd         : std_logic := 'X';
   SIGNAL d30_ipd         : std_logic := 'X';
   SIGNAL d31_ipd         : std_logic := 'X';
   SIGNAL sd1_ipd        : std_logic := 'X';
   SIGNAL sd2_ipd        : std_logic := 'X';
   SIGNAL sd3_ipd        : std_logic := 'X';
   SIGNAL sd4_ipd        : std_logic := 'X';
   SIGNAL sd5_ipd        : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (d0_ipd, d0, tipd_d0);
   VitalWireDelay (d1_ipd, d1, tipd_d1);
   VitalWireDelay (d2_ipd, d2, tipd_d2);
   VitalWireDelay (d3_ipd, d3, tipd_d3);
   VitalWireDelay (d4_ipd, d4, tipd_d4);
   VitalWireDelay (d5_ipd, d5, tipd_d5);
   VitalWireDelay (d6_ipd, d6, tipd_d6);
   VitalWireDelay (d7_ipd, d7, tipd_d7);
   VitalWireDelay (d8_ipd, d8, tipd_d8);
   VitalWireDelay (d9_ipd, d9, tipd_d9);
   VitalWireDelay (d10_ipd, d10, tipd_d10);
   VitalWireDelay (d11_ipd, d11, tipd_d11);
   VitalWireDelay (d12_ipd, d12, tipd_d12);
   VitalWireDelay (d13_ipd, d13, tipd_d13);
   VitalWireDelay (d14_ipd, d14, tipd_d14);
   VitalWireDelay (d15_ipd, d15, tipd_d15);
   VitalWireDelay (d16_ipd, d16, tipd_d16);
   VitalWireDelay (d17_ipd, d17, tipd_d17);
   VitalWireDelay (d18_ipd, d18, tipd_d18);
   VitalWireDelay (d19_ipd, d19, tipd_d19);
   VitalWireDelay (d20_ipd, d20, tipd_d20);
   VitalWireDelay (d21_ipd, d21, tipd_d21);
   VitalWireDelay (d22_ipd, d22, tipd_d22);
   VitalWireDelay (d23_ipd, d23, tipd_d23);
   VitalWireDelay (d24_ipd, d24, tipd_d24);
   VitalWireDelay (d25_ipd, d25, tipd_d25);
   VitalWireDelay (d26_ipd, d26, tipd_d26);
   VitalWireDelay (d27_ipd, d27, tipd_d27);
   VitalWireDelay (d28_ipd, d28, tipd_d28);
   VitalWireDelay (d29_ipd, d29, tipd_d29);
   VitalWireDelay (d30_ipd, d30, tipd_d30);
   VitalWireDelay (d31_ipd, d31, tipd_d31);
   VitalWireDelay (sd1_ipd, sd1, tipd_sd1);
   VitalWireDelay (sd2_ipd, sd2, tipd_sd2);
   VitalWireDelay (sd3_ipd, sd3, tipd_sd3);
   VitalWireDelay (sd4_ipd, sd4, tipd_sd4);
   VitalWireDelay (sd5_ipd, sd5, tipd_sd5);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (d0_ipd, d1_ipd, d2_ipd, d3_ipd, d4_ipd, d5_ipd, d6_ipd, d7_ipd, d8_ipd, d9_ipd, d10_ipd, d11_ipd, d12_ipd, d13_ipd, d14_ipd, d15_ipd, d16_ipd, d17_ipd, d18_ipd, d19_ipd, d20_ipd, d21_ipd, d22_ipd, d23_ipd, d24_ipd, d25_ipd, d26_ipd, d27_ipd, d28_ipd, d29_ipd, d30_ipd, d31_ipd, sd1_ipd, sd2_ipd, sd3_ipd, sd4_ipd, sd5_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (d31_ipd, d30_ipd, d29_ipd, d28_ipd, d27_ipd, d26_ipd, d25_ipd, d24_ipd, d23_ipd, d22_ipd, d21_ipd, d20_ipd, d19_ipd, d18_ipd, d17_ipd, d16_ipd, d15_ipd, d14_ipd, d13_ipd, d12_ipd, d11_ipd, d10_ipd, d9_ipd, d8_ipd, d7_ipd, d6_ipd, d5_ipd, d4_ipd, d3_ipd, d2_ipd, d1_ipd, d0_ipd),
                  dselect => (sd5_ipd, sd4_ipd, sd3_ipd, sd2_ipd, sd1_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
          Paths => (0 => (d0_ipd'last_event, tpd_d0_z, TRUE),
                 1 => (d1_ipd'last_event, tpd_d1_z, TRUE),
                 2 => (d2_ipd'last_event, tpd_d2_z, TRUE),
                 3 => (d3_ipd'last_event, tpd_d3_z, TRUE),
                 4 => (d4_ipd'last_event, tpd_d4_z, TRUE),
                 5 => (d5_ipd'last_event, tpd_d5_z, TRUE),
                 6 => (d6_ipd'last_event, tpd_d6_z, TRUE),
                 7 => (d7_ipd'last_event, tpd_d7_z, TRUE),
                 8 => (d8_ipd'last_event, tpd_d8_z, TRUE),
                 9 => (d9_ipd'last_event, tpd_d9_z, TRUE),
                 10 => (d10_ipd'last_event, tpd_d10_z, TRUE),
                 11 => (d11_ipd'last_event, tpd_d11_z, TRUE),
                 12 => (d12_ipd'last_event, tpd_d12_z, TRUE),
                 13 => (d13_ipd'last_event, tpd_d13_z, TRUE),
                 14 => (d14_ipd'last_event, tpd_d14_z, TRUE),
                 15 => (d15_ipd'last_event, tpd_d15_z, TRUE),
                 16 => (d16_ipd'last_event, tpd_d16_z, TRUE),
                 17 => (d17_ipd'last_event, tpd_d17_z, TRUE),
                 18 => (d18_ipd'last_event, tpd_d18_z, TRUE),
                 19 => (d19_ipd'last_event, tpd_d19_z, TRUE),
                 20 => (d20_ipd'last_event, tpd_d20_z, TRUE),
                 21 => (d21_ipd'last_event, tpd_d21_z, TRUE),
                 22 => (d22_ipd'last_event, tpd_d22_z, TRUE),
                 23 => (d23_ipd'last_event, tpd_d23_z, TRUE),
                 24 => (d24_ipd'last_event, tpd_d24_z, TRUE),
                 25 => (d25_ipd'last_event, tpd_d25_z, TRUE),
                 26 => (d26_ipd'last_event, tpd_d26_z, TRUE),
                 27 => (d27_ipd'last_event, tpd_d27_z, TRUE),
                 28 => (d28_ipd'last_event, tpd_d28_z, TRUE),
                 29 => (d29_ipd'last_event, tpd_d29_z, TRUE),
                 30 => (d30_ipd'last_event, tpd_d30_z, TRUE),
                 31 => (d31_ipd'last_event, tpd_d31_z, TRUE),
                 32 => (sd1_ipd'last_event, tpd_sd1_z, TRUE),
                 33 => (sd2_ipd'last_event, tpd_sd2_z, TRUE),
                 34 => (sd3_ipd'last_event, tpd_sd3_z, TRUE),
                 35 => (sd4_ipd'last_event, tpd_sd4_z, TRUE),
                36 => (sd5_ipd'last_event, tpd_sd5_z, TRUE)),

       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;



--
----- cell nd2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nd2 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nd2";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nd2 : ENTITY IS TRUE;

END nd2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nd2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd AND b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nd3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nd3 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nd3";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nd3 : ENTITY IS TRUE;

END nd3;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nd3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	: std_logic := 'X';
   SIGNAL b_ipd	: std_logic := 'X';
   SIGNAL c_ipd	: std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd AND b_ipd AND c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nd4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nd4 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nd4";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nd4 : ENTITY IS TRUE;

END nd4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nd4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd AND b_ipd AND c_ipd AND d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nd5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nd5 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nd5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nd5 : ENTITY IS TRUE;

END nd5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nd5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd AND b_ipd AND c_ipd AND d_ipd AND e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nr2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nr2 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nr2";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nr2 : ENTITY IS TRUE;

END nr2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nr2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd OR b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nr3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nr3 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nr3";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nr3 : ENTITY IS TRUE;

END nr3;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nr3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd OR b_ipd OR c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nr4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nr4 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nr4";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nr4 : ENTITY IS TRUE;

END nr4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nr4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd OR b_ipd OR c_ipd OR d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell nr5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY nr5 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "nr5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF nr5 : ENTITY IS TRUE;

END nr5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF nr5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd OR b_ipd OR c_ipd OR d_ipd OR e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell or2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY or2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "or2";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF or2 : ENTITY IS TRUE;

END or2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF or2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd OR b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell or3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY or3 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "or3";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF or3 : ENTITY IS TRUE;

END or3;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF or3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd OR b_ipd OR c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell or4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY or4 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "or4";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF or4 : ENTITY IS TRUE;

END or4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF or4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd OR b_ipd OR c_ipd OR d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell or5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY or5 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "or5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF or5 : ENTITY IS TRUE;

END or5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF or5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd OR b_ipd OR c_ipd OR d_ipd OR e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell pfumx -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY pfumx IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "pfumx";
      tpd_c0_z        :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_alut_z      :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_blut_z      :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_alut       :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_blut       :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c0         :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      alut            :	IN    std_logic;
      blut            :	IN    std_logic;
      c0              :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF pfumx : ENTITY IS TRUE;

END pfumx;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF pfumx IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL alut_ipd	 : std_logic := 'X';
   SIGNAL blut_ipd	 : std_logic := 'X';
   SIGNAL c0_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (alut_ipd, alut, tipd_alut);
   VitalWireDelay (blut_ipd, blut, tipd_blut);
   VitalWireDelay (c0_ipd, c0, tipd_c0);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (alut_ipd, blut_ipd, c0_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := vitalmux
                 (data => (alut_ipd, blut_ipd),
                  dselect => (0 => c0_ipd));

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (c0_ipd'last_event, tpd_c0_z, TRUE),
                 1 => (alut_ipd'last_event, tpd_alut_z, TRUE),
                 2 => (blut_ipd'last_event, tpd_blut_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;



--
----- cell strtup -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;


-- entity declaration --
ENTITY strtup IS
   GENERIC (
      TimingChecksOn	 : Boolean := TRUE;
      XOn		 : Boolean := FALSE;        
      MsgOn		 : Boolean := FALSE;
      InstancePath	 : String  := "strtup");

   PORT(
      uclk		 : in std_logic);

    ATTRIBUTE Vital_Level0 OF strtup : ENTITY IS TRUE;
 
END strtup ;

-- ARCHITECTURE body --
ARCHITECTURE V OF strtup IS
    ATTRIBUTE Vital_Level0 OF V : ARCHITECTURE IS TRUE;

BEGIN

END V;


--
----- cell vhi -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY vhi IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "vhi");

   PORT(
      z               :	OUT  std_logic := '1');

   ATTRIBUTE Vital_Level0 OF vhi : ENTITY IS TRUE;

END vhi;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF vhi IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   --  empty
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   z <= '1';



END v;


--
----- cell vlo -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY vlo IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "vlo");

   PORT(
      z               :	OUT  std_logic := '0');

   ATTRIBUTE Vital_Level0 OF vlo : ENTITY IS TRUE;

END vlo;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF vlo IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   --  empty
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   z <= '0';



END v;


--
----- cell xnor2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xnor2 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "xnor2";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xnor2 : ENTITY IS TRUE;

END xnor2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xnor2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd XOR b_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xnor3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xnor3 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "xnor3";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xnor3 : ENTITY IS TRUE;

END xnor3;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xnor3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd XOR b_ipd XOR c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xnor4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xnor4 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "xnor4";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xnor4 : ENTITY IS TRUE;

END xnor4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xnor4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;

--
----- cell xnor5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xnor5 IS
   GENERIC(
      TimingChecksOn  : boolean := FALSE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := FALSE;
      InstancePath    : string := "xnor5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xnor5 : ENTITY IS TRUE;

END xnor5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xnor5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := NOT (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd XOR e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor2 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor2 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor2";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      z               :	OUT   std_logic);

   ATTRIBUTE Vital_Level0 OF xor2 : ENTITY IS TRUE;

END xor2;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor2 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd);
       
      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor3 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor3 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor3";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xor3 : ENTITY IS TRUE;

END xor3;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor3 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd XOR c_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor4 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor4 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor4";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xor4 : ENTITY IS TRUE;

END xor4;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor4 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor5 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor5 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor5";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a               :	IN    std_logic;
      b               :	IN    std_logic;
      c               :	IN    std_logic;
      d               :	IN    std_logic;
      e               :	IN    std_logic;
      z               :	OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF xor5 : ENTITY IS TRUE;

END xor5;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor5 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd)


   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd XOR e_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor11 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor11 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor11";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_f_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_g_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_h_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_i_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_j_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_k_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_f          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_g          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_h          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_j          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_k          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a, b, c, d, e, f, g, h, i, j, k : IN std_logic;
      z                               : OUT std_logic);

   ATTRIBUTE Vital_Level0 OF xor11 : ENTITY IS TRUE;

END xor11;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor11 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';
   SIGNAL f_ipd	 : std_logic := 'X';
   SIGNAL g_ipd	 : std_logic := 'X';
   SIGNAL h_ipd	 : std_logic := 'X';
   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL j_ipd	 : std_logic := 'X';
   SIGNAL k_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   VitalWireDelay (f_ipd, f, tipd_f);
   VitalWireDelay (g_ipd, g, tipd_g);
   VitalWireDelay (h_ipd, h, tipd_h);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (j_ipd, j, tipd_j);
   VitalWireDelay (k_ipd, k, tipd_k);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd, f_ipd, 
		g_ipd, h_ipd, i_ipd, j_ipd, k_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd XOR e_ipd xor
		f_ipd XOR g_ipd XOR h_ipd XOR i_ipd XOR j_ipd XOR 
		k_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE),
                 5 => (f_ipd'last_event, tpd_f_z, TRUE),
                 6 => (g_ipd'last_event, tpd_g_z, TRUE),
                 7 => (h_ipd'last_event, tpd_h_z, TRUE),
                 8 => (i_ipd'last_event, tpd_i_z, TRUE),
                 9 => (j_ipd'last_event, tpd_j_z, TRUE),
                10 => (k_ipd'last_event, tpd_k_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell xor21 -----
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY xor21 IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "xor21";
      tpd_a_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_b_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_c_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_d_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_e_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_f_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_g_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_h_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_i_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_j_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_k_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_l_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_m_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_n_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_o_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_p_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_q_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_r_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_s_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_t_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tpd_u_z         :	VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_b          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_c          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_d          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_e          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_f          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_g          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_h          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_i          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_j          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_k          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_l          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_m          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_n          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_o          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_p          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_q          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_r          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_s          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_t          :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_u          :	VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      a, b, c, d, e, f, g, h, i, j, k : IN std_logic;
      l, m, n, o, p, q, r, s, t, u    : IN std_logic;
      z				      :	OUT std_logic);

   ATTRIBUTE Vital_Level0 OF xor21 : ENTITY IS TRUE;

END xor21;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF xor21 IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;

   SIGNAL a_ipd	 : std_logic := 'X';
   SIGNAL b_ipd	 : std_logic := 'X';
   SIGNAL c_ipd	 : std_logic := 'X';
   SIGNAL d_ipd	 : std_logic := 'X';
   SIGNAL e_ipd	 : std_logic := 'X';
   SIGNAL f_ipd	 : std_logic := 'X';
   SIGNAL g_ipd	 : std_logic := 'X';
   SIGNAL h_ipd	 : std_logic := 'X';
   SIGNAL i_ipd	 : std_logic := 'X';
   SIGNAL j_ipd	 : std_logic := 'X';
   SIGNAL k_ipd	 : std_logic := 'X';
   SIGNAL l_ipd	 : std_logic := 'X';
   SIGNAL m_ipd	 : std_logic := 'X';
   SIGNAL n_ipd	 : std_logic := 'X';
   SIGNAL o_ipd	 : std_logic := 'X';
   SIGNAL p_ipd	 : std_logic := 'X';
   SIGNAL q_ipd	 : std_logic := 'X';
   SIGNAL r_ipd	 : std_logic := 'X';
   SIGNAL s_ipd	 : std_logic := 'X';
   SIGNAL t_ipd	 : std_logic := 'X';
   SIGNAL u_ipd	 : std_logic := 'X';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   VitalWireDelay (b_ipd, b, tipd_b);
   VitalWireDelay (c_ipd, c, tipd_c);
   VitalWireDelay (d_ipd, d, tipd_d);
   VitalWireDelay (e_ipd, e, tipd_e);
   VitalWireDelay (f_ipd, f, tipd_f);
   VitalWireDelay (g_ipd, g, tipd_g);
   VitalWireDelay (h_ipd, h, tipd_h);
   VitalWireDelay (i_ipd, i, tipd_i);
   VitalWireDelay (j_ipd, j, tipd_j);
   VitalWireDelay (k_ipd, k, tipd_k);
   VitalWireDelay (l_ipd, l, tipd_l);
   VitalWireDelay (m_ipd, m, tipd_m);
   VitalWireDelay (n_ipd, n, tipd_n);
   VitalWireDelay (o_ipd, o, tipd_o);
   VitalWireDelay (p_ipd, p, tipd_p);
   VitalWireDelay (q_ipd, q, tipd_q);
   VitalWireDelay (r_ipd, r, tipd_r);
   VitalWireDelay (s_ipd, s, tipd_s);
   VitalWireDelay (t_ipd, t, tipd_t);
   VitalWireDelay (u_ipd, u, tipd_u);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd, b_ipd, c_ipd, d_ipd, e_ipd, f_ipd, 
		g_ipd, h_ipd, i_ipd, j_ipd, k_ipd, l_ipd, m_ipd, n_ipd,
		o_ipd, p_ipd, q_ipd, r_ipd, s_ipd, t_ipd, u_ipd)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData	: VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
      z_zd := (a_ipd XOR b_ipd XOR c_ipd XOR d_ipd XOR e_ipd xor
		f_ipd XOR g_ipd XOR h_ipd XOR i_ipd XOR j_ipd XOR 
		k_ipd XOR l_ipd XOR m_ipd XOR n_ipd XOR o_ipd xor
		p_ipd) XOR (q_ipd XOR r_ipd XOR s_ipd XOR t_ipd XOR 
		u_ipd);

      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, tpd_a_z, TRUE),
                 1 => (b_ipd'last_event, tpd_b_z, TRUE),
                 2 => (c_ipd'last_event, tpd_c_z, TRUE),
                 3 => (d_ipd'last_event, tpd_d_z, TRUE),
                 4 => (e_ipd'last_event, tpd_e_z, TRUE),
                 5 => (f_ipd'last_event, tpd_f_z, TRUE),
                 6 => (g_ipd'last_event, tpd_g_z, TRUE),
                 7 => (h_ipd'last_event, tpd_h_z, TRUE),
                 8 => (i_ipd'last_event, tpd_i_z, TRUE),
                 9 => (j_ipd'last_event, tpd_j_z, TRUE),
                10 => (k_ipd'last_event, tpd_k_z, TRUE),
                11 => (l_ipd'last_event, tpd_l_z, TRUE),
                12 => (m_ipd'last_event, tpd_m_z, TRUE),
                13 => (n_ipd'last_event, tpd_n_z, TRUE),
                14 => (o_ipd'last_event, tpd_o_z, TRUE),
                15 => (p_ipd'last_event, tpd_p_z, TRUE),
                16 => (q_ipd'last_event, tpd_q_z, TRUE),
                17 => (r_ipd'last_event, tpd_r_z, TRUE),
                18 => (s_ipd'last_event, tpd_s_z, TRUE),
                19 => (t_ipd'last_event, tpd_t_z, TRUE),
                20 => (u_ipd'last_event, tpd_u_z, TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);


END PROCESS;

END v;


--
----- cell bufba -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
 
 
-- entity declaration --
ENTITY bufba IS
   GENERIC(
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "bufba";
      tpd_a_z         : VitalDelayType01 := (0.01 ns, 0.01 ns);
      tipd_a          : VitalDelayType01 := (0.0 ns, 0.0 ns));
 
   PORT(
      a               : IN   std_logic;
      z               : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF bufba : ENTITY IS TRUE;
 
END bufba;
 
-- architecture body --
ARCHITECTURE v OF bufba IS
   ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL a_ipd  : std_logic := 'X';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (a_ipd, a, tipd_a);
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : PROCESS (a_ipd)
 
   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd : std_ulogic IS results(1);
 
   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData        : VitalGlitchDataType;
 
   BEGIN
 
      -------------------------
      --  functionality section
      -------------------------
      z_zd := VitalBUF(a_ipd);
 
      ----------------------
      --  path delay section
      ----------------------
      VitalPathDelay01 (
       OutSignal => z,
       OutSignalName => "z",
       OutTemp => z_zd,
       Paths => (0 => (a_ipd'last_event, (tpd_a_z), TRUE)),
       GlitchData => z_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);
 
END PROCESS;
 
END v;
 
 

-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_MISC.vhd,v 1.1 2005/12/06 13:00:24 tame Exp $
--
--
----- cell dcs -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;


-- entity declaration --
ENTITY dcs IS
   GENERIC(
      DCSMODE         : String  := "POS";
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "dcs";
      tpd_clk0_dcsout        : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_clk1_dcsout        : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tpd_sel_dcsout        : VitalDelayType01 := (0.001 ns, 0.001 ns);
      tipd_clk0         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_clk1         : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_sel         : VitalDelayType01 := (0.0 ns, 0.0 ns));

   PORT(
      clk0              : IN    std_logic;
      clk1              : IN    std_logic;
      sel              : IN    std_logic;
      dcsout               : OUT  std_logic);

   ATTRIBUTE Vital_Level0 OF dcs : ENTITY IS TRUE;

END dcs;

-- architecture body --

LIBRARY ieee;
USE ieee.vital_primitives.all;
ARCHITECTURE v OF dcs IS
   ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL clk0_ipd         : std_logic := 'X';
   SIGNAL clk1_ipd         : std_logic := 'X';
   SIGNAL sel_ipd         : std_logic := 'X';
   SIGNAL sel_int1        : std_logic := '0';
   SIGNAL sel_int2        : std_logic := '0';
   SIGNAL sel_int3        : std_logic_vector(1 downto 0) := "00";
   SIGNAL dcsout_int1         : std_logic := '0';
   SIGNAL sel_int4        : std_logic := '0';
   SIGNAL sel_int5        : std_logic := '0';
   SIGNAL sel_int6        : std_logic_vector(1 downto 0) := "00";
   SIGNAL dcsout_int2         : std_logic := '0';
   SIGNAL sel_int7        : std_logic := '0';
   SIGNAL sel_int8        : std_logic := '0';
   SIGNAL sel_int9        : std_logic := '0';
   SIGNAL sel_int10       : std_logic := '0';
   SIGNAL dcsout_int3         : std_logic := '0';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay (clk0_ipd, clk0, tipd_clk0);
   VitalWireDelay (clk1_ipd, clk1, tipd_clk1);
   VitalWireDelay (sel_ipd, sel, tipd_sel);
   END BLOCK;
   --------------------
   --  behavior section
   --------------------
   P1 : PROCESS (clk0_ipd, clk1_ipd)
   BEGIN
        IF (clk0_ipd'event and clk0_ipd = '0') THEN
           IF (sel_ipd = '1') THEN
              sel_int1 <= sel_ipd;
           END IF;
--           ELSIF (sel_ipd = '0') THEN
           IF (sel_int1 = '0') THEN
              sel_int2 <= sel_int1;
           END IF;
        END IF;
        IF (clk1_ipd'event and clk1_ipd = '0') THEN
           IF (sel_ipd = '0') THEN
              sel_int1 <= sel_ipd;
           END IF;
--           ELSIF (sel_ipd = '1') THEN
           IF (sel_int1 = '1') THEN
              sel_int2 <= sel_int1;
           END IF;
        END IF;
   END PROCESS;       

   sel_int3 <= (sel_int2, sel_int1);

   P2 : PROCESS (clk0_ipd, clk1_ipd, sel_int3)
   BEGIN
        case sel_int3 is
           when "00" => dcsout_int1 <= clk0_ipd;
           when "01" => dcsout_int1 <= '0';
           when "10" => dcsout_int1 <= '0';
           when "11" => dcsout_int1 <= clk1_ipd;
           when others => NULL;
        end case;
   END PROCESS;

   P3 : PROCESS (clk0_ipd, clk1_ipd)
   BEGIN
        IF (clk0_ipd'event and clk0_ipd = '1') THEN
           IF (sel_ipd = '1') THEN
              sel_int4 <= sel_ipd;
           END IF;
           IF (sel_int4 = '0') THEN
              sel_int5 <= sel_int4;
           END IF;
        END IF;
        IF (clk1_ipd'event and clk1_ipd = '1') THEN
           IF (sel_ipd = '0') THEN
              sel_int4 <= sel_ipd;
           END IF;
           IF (sel_int4 = '1') THEN
              sel_int5 <= sel_int4;
           END IF;
        END IF;
   END PROCESS;

   sel_int6 <= (sel_int5, sel_int4);

   P4 : PROCESS (clk0_ipd, clk1_ipd, sel_int6)
   BEGIN
        case sel_int6 is
           when "00" => dcsout_int2 <= clk0_ipd;
           when "01" => dcsout_int2 <= '1';
           when "10" => dcsout_int2 <= '1';
           when "11" => dcsout_int2 <= clk1_ipd;
           when others => NULL;
        end case;
   END PROCESS;

   P7 : PROCESS (clk1_ipd)
   BEGIN
      IF (clk1_ipd'event and clk1_ipd = '0') THEN
            sel_int7 <= sel_ipd;
      END IF;
   END PROCESS;

   P8 : PROCESS (clk0_ipd)
   BEGIN
      IF (clk0_ipd'event and clk0_ipd = '0') THEN
            sel_int8 <= sel_ipd;
      END IF;
   END PROCESS;

   P9 : PROCESS (clk1_ipd)
   BEGIN
      IF (clk1_ipd'event and clk1_ipd = '1') THEN
            sel_int9 <= sel_ipd;
      END IF;
   END PROCESS;

   P10 : PROCESS (clk0_ipd)
   BEGIN
      IF (clk0_ipd'event and clk0_ipd = '1') THEN
            sel_int10 <= sel_ipd;
      END IF;
   END PROCESS;

   P11 : PROCESS (clk0_ipd, clk1_ipd, sel_ipd, sel_int7, sel_int8, sel_int9, sel_int10)
   BEGIN
      IF (DCSMODE = "HIGH_LOW") THEN
        dcsout_int3 <= vitalmux 
                          (data => (clk1_ipd, '0'),
                           dselect => (0 => sel_int7));
      ELSIF (DCSMODE = "HIGH_HIGH") THEN
        dcsout_int3 <= vitalmux 
                          (data => (clk1_ipd, '1'),
                           dselect => (0 => sel_int9));
      ELSIF (DCSMODE = "LOW_LOW") THEN
        dcsout_int3 <= vitalmux 
                          (data => ('0', clk0_ipd),
                           dselect => (0 => sel_int8));
      ELSIF (DCSMODE = "LOW_HIGH") THEN
        dcsout_int3 <= vitalmux 
                          (data => ('1', clk0_ipd),
                           dselect => (0 => sel_int10));
      ELSIF (DCSMODE = "CLK0") THEN
        dcsout_int3 <= vitalmux 
                          (data => (clk0_ipd, clk0_ipd),
                           dselect => (0 => sel_ipd));
      ELSIF (DCSMODE = "CLK1") THEN
        dcsout_int3 <= vitalmux 
                          (data => (clk1_ipd, clk1_ipd),
                           dselect => (0 => sel_ipd));
      END IF;
   END PROCESS;

   VitalBehavior : PROCESS (dcsout_int1, dcsout_int2, dcsout_int3)

   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS dcsout_zd       : std_ulogic IS results(1);

   -- output glitch detection VARIABLEs
   VARIABLE dcsout_GlitchData        : VitalGlitchDataType;

   BEGIN

      -------------------------
      --  functionality section
      -------------------------
   IF (DCSMODE = "NEG") THEN
      dcsout_zd := dcsout_int1;
   ELSIF (DCSMODE = "POS") THEN
      dcsout_zd := dcsout_int2;
   ELSE
      dcsout_zd := dcsout_int3;
   END IF;       

    -----------------------------------
    -- Path Delay Section.
    -----------------------------------
      VitalPathDelay01 (
       OutSignal => dcsout,
       OutSignalName => "dcsout",
       OutTemp => dcsout_zd,
       Paths => (0 => (clk0_ipd'last_event, tpd_clk0_dcsout, TRUE),
                 1 => (clk1_ipd'last_event, tpd_clk1_dcsout, TRUE),
                 2 => (sel_ipd'last_event, tpd_sel_dcsout, TRUE)),
       GlitchData => dcsout_GlitchData,
       Mode => OnDetect,
       XOn => XOn,
       MsgOn => MsgOn);

END PROCESS;

END v;



--******************************************************************
----- VITAL model for cell GENERIC_PLLB -----
--******************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.VITAL_Timing.all;
library ec;
use ec.components.all;

-- entity declaration --
entity GENERIC_PLLB is
   generic(
   
     
      FIN  : string  := "100.0";
      CLKI_DIV      : string  := "1";
      CLKOP_DIV     : string  := "1";
      CLKFB_DIV     : string  := "1";
      FDEL  : string  := "1";
      FB_MODE  : string  := "CLOCKTREE";
      CLKOK_DIV   : string   := "2";
      WAKE_ON_LOCK  : string  := "off";
      DELAY_CNTL    : string  := "STATIC";
      PHASEADJ       :  string  := "0";
      DUTY        :  string  := "4";
      lock_cyc : integer := 2;
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;
      tpd_RST_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOP :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_CLKI    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CLKFB   :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_RST   :	VitalDelayType01 := (0.000 ns, 0.000 ns)
   );

   port(
      CLKI            : in    STD_ULOGIC;
      CLKFB           : in    STD_ULOGIC;
      RST           : in    STD_ULOGIC := '0';

      DDAMODE            : in    STD_ULOGIC;
      DDAIZR            : in    STD_ULOGIC;
      DDAILAG           : in    STD_ULOGIC;
      DDAIDEL0          : in    STD_ULOGIC;
      DDAIDEL1          : in    STD_ULOGIC;
      DDAIDEL2          : in    STD_ULOGIC;

      CLKOP           : out   STD_ULOGIC;
      CLKOS          : out   STD_ULOGIC;
      CLKOK           : out   STD_ULOGIC;
      LOCK          : out   STD_ULOGIC;

      DDAOZR           : out   STD_ULOGIC;
      DDAOLAG          : out   STD_ULOGIC;
      DDAODEL0         : out   STD_ULOGIC;
      DDAODEL1         : out   STD_ULOGIC;
      DDAODEL2         : out   STD_ULOGIC
);
--attribute VITAL_LEVEL0 of GENERIC_PLLB : entity is FALSE;
end GENERIC_PLLB;

-- architecture body --

architecture V of GENERIC_PLLB is
  attribute VITAL_LEVEL1 of V : architecture is FALSE;

  SIGNAL CLKI_ipd	 : STD_ULOGIC := 'X';
  SIGNAL RST_ipd	 : STD_ULOGIC := 'X';

  CONSTANT input_frequency : REAL := str2real(FIN);
  SIGNAL start_inclk : STD_LOGIC ;
  SIGNAL clklock_half_period1 : TIME :=100 ns;
  SIGNAL clklock_half_period0 : TIME :=100 ns;
  SIGNAL clklock_half_period : TIME :=100 ns;
 
  SIGNAL clklock_period : TIME :=100 ns;
  SIGNAL clklock_half_period_minus_dly1 : TIME :=100 ns;
  SIGNAL clklock_half_period_minus_dly0 : TIME :=100 ns;
  SIGNAL secd_delay_minus1 : TIME :=100 ns;
  SIGNAL secd_delay_minus0 : TIME :=100 ns;
  SIGNAL clklock_rising_edge_count : INTEGER := 0 ;
  SIGNAL clklock_falling_edge_count : INTEGER := 0 ;
  SIGNAL clklock_last_rising_edge : TIME ;
  SIGNAL clklock_last_falling_edge : TIME ;

  SIGNAL clkop_err_0 : TIME := 0 ns;
  SIGNAL clkop_err_1 : TIME := 0 ns;
  
  SIGNAL clock_count : INTEGER := -1 ;
  SIGNAL clock_f_count : INTEGER := -1 ;
  SIGNAL clklock_lock : BOOLEAN := TRUE;
  SIGNAL CLK_OUT_sig_d  : std_logic := '0';
  SIGNAL CLK_OUT_sig_d_not  : std_logic := '0';
  SIGNAL CLK_OUT_sig_3d  : std_logic := '0';
  SIGNAL CLK_OUT_sig_3d_not  : std_logic := '0';
  SIGNAL CLK_OUT_sig_d_start  : std_logic := '0';
  SIGNAL CLK_OUT_start  : std_logic := '0';
  SIGNAL CLK_OUT_plus_delay : std_logic := '0';
  SIGNAL SEC_OUT_sig_d  : std_logic := '0';
  SIGNAL SEC_OUT_sig_d_not  : std_logic := '0';
  SIGNAL SEC_OUT_sig_3d  : std_logic := '0';
  SIGNAL SEC_OUT_sig_3d_not  : std_logic := '0';
  SIGNAL SEC_OUT_sig_d_start  : std_logic := '0';
  SIGNAL SEC_OUT_start  : std_logic := '0';
  SIGNAL SEC_OUT_plus_delay : std_logic := '0';
  SIGNAL CLK_OUT_sig1 : std_logic := '0';
  SIGNAL PLL_LOCK_plus : std_logic := '0';
  SIGNAL PLL_LOCK_minus : std_logic := '0';

  CONSTANT secdiv_p: integer := str2int(CLKOK_DIV);
  CONSTANT clockboost: real := real(str2int(CLKFB_DIV)) / real(str2int(CLKI_DIV));
  CONSTANT div_r: real :=  real(str2int(CLKI_DIV));
  CONSTANT mult_r: real := real(str2int(CLKFB_DIV));

  CONSTANT div_i: integer :=  str2int(CLKI_DIV);
  CONSTANT mult_i: integer  := str2int(CLKFB_DIV);
  
  SIGNAL  RST_int  : STD_LOGIC:= '0';
  SIGNAL  RST_int_o : STD_LOGIC:= '0'; --071504
  SIGNAL  RST_int_o2 : STD_LOGIC:= '0'; --081504
  
  SIGNAL clkp_half_period1 : TIME :=100 ns;
  SIGNAL clkp_half_period0 : TIME :=100 ns;
  SIGNAL phase_shift : TIME :=0 ns;
  SIGNAL phase_shift_value : integer := 0;
  CONSTANT duty_i: integer := str2int(duty);
  CONSTANT phase_i: integer := str2int(PHASEADJ);

  SIGNAL CLKP_OUT_sig_d  : std_logic := '0';
  SIGNAL CLKP_OUT_sig_d_not  : std_logic := '0';
  SIGNAL CLKP_OUT_sig_3d  : std_logic := '0';
  SIGNAL CLKP_OUT_sig_3d_not  : std_logic := '0';
  SIGNAL CLKP_OUT_plus_delay : std_logic := '0';
  SIGNAL CLKP_OUT_sig_d_start  : std_logic := '0';
  SIGNAL CLKP_OUT_start  : std_logic := '0';

  SIGNAL pll_dly_user     : integer := str2int(FDEL);
  SIGNAL pll_dly_value    : integer := 0;
  SIGNAL pll_dly_values   : integer := 0;
  SIGNAL pll_dly_valued   : integer := 0;

  SIGNAL clklock_period_c1 : TIME := 0 ns;
  SIGNAL clklock_period_c2 : TIME := 0 ns;
  SIGNAL clklock_period_c3 : TIME := 0 ns;

  SIGNAL clk_lock_o :  std_logic := '1';  --071404
  SIGNAL clk_lock_o2 :  std_logic := '1';  --081504
  SIGNAL clk_lock :  std_logic := '1'; 

  SIGNAL lock_int1 : std_logic; 

  SIGNAL tpd: time; 
  SIGNAL tpd_r1: time := 0 ns; 
  SIGNAL tpd_r2: time := 0 ns; 
  SIGNAL tpd_r3: time := 0 ns; 
  SIGNAL tpd_r4: time := 0 ns; 
  SIGNAL tpd_f1: time := 0 ns; 
  SIGNAL tpd_f2: time := 0 ns; 
  SIGNAL tpd_f3: time := 0 ns; 
  SIGNAL tpd_f4: time := 0 ns; 

  SIGNAL DDA_DLY : std_logic_vector(2 downto 0); 

  SIGNAL op_i, os_i, ok_i   : integer := 0;

--------------------------------------------------------------------------------
  signal old_clkop, old_clkos, old_clkok : std_logic;
  signal new_clkop, new_clkos, new_clkok : std_logic; 

  --signal new_clkop_tmp, new_clkos_tmp, new_clkok_tmp : std_logic_vector(99 downto 0); --071304
  signal use_new_clk_op, use_new_clk_os, use_new_clk_ok : std_logic := '0';
  signal old_lock : std_logic;
  SIGNAL CLKOP1   : std_logic := '0';
  SIGNAL CLKOS1   : std_logic := '0';
  SIGNAL clk_first_time   : std_logic := '1';
  SIGNAL fb_count           : Integer := 0;

  
  ---------------signal clkop_period : time := 10 ns;
  signal clkin_period : time := 10 ns; --071304
  signal clkref_rise1 : time:=0 ns;
  ---------signal op_low2high : time:=0 ns;
  signal ref2fb_dly : time:=0 ns;
  signal ref2fb_dly_tmp : time:=0 ns;
  signal fb_dly_rdy : std_logic := '0'; --071404
  signal fb_dly_rdy_r1 : std_logic := '0'; --071404
  signal fb_low2high: time:=0 ns;
  
  signal fb_adjust : time:=0 ns;
  signal fb_adjust_divide_by_100 : time:=0 ns; --071304
  signal last_fb_adjust : time:=0 ns;
  
  signal clkref : std_logic := '0';
  
  signal rst_pause : time := 1 ns; --081504
  
  type state_val is 
  ( WAIT_OLD_LOCK_FALL, WAIT_OLD_LOCK_RISE, 
  WAIT_CLKREF_RISE1, 
  WAIT_CLKFB_RISE, 
  WAIT_NEW_CLKOP_FALL,  WAIT_NEW_CLKOS_CLKOK_FALL,
  WAIT_NEW_CLKOK_FALL, WAIT_NEW_CLKOS_FALL);
  
  signal state: state_val := WAIT_OLD_LOCK_RISE;
  
   
  SIGNAL clkin_half_period0 : TIME :=100 ns; --071304
  SIGNAL clkin_half_period1 : TIME :=100 ns; --071304
 
---------------------------------------------------------------
BEGIN
---------------------------------------------------------------


   ------------------------------------------------------------------
   -- State Machine
   ------------------------------------------------------------------
   process (old_lock, clkref, CLKFB, new_clkop, new_clkok, new_clkos)
   
      variable ref2fb_dly_tmp : time := 0 ns;
   begin
      
      case state is
         --when IDLE =>
         when WAIT_OLD_LOCK_FALL =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
            end if;
         ----------------------------------------------------
         when WAIT_OLD_LOCK_RISE =>
            if rising_edge (old_lock) then
               state <= WAIT_CLKREF_RISE1;
            end if;
         ----------------------------------------------------
         
         when WAIT_CLKREF_RISE1 =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404

            elsif rising_edge(clkref) then
               state <= WAIT_CLKFB_RISE;
               clkref_rise1 <= now;
            end if;
         ----------------------------------------------------
         when WAIT_CLKFB_RISE =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
               
            elsif rising_edge(CLKFB) then
               state <= WAIT_NEW_CLKOP_FALL;

               if now - clkref_rise1 /= clkin_period then
                  ref2fb_dly_tmp := now - clkref_rise1 ;
               else 
                  ref2fb_dly_tmp := 0 ns ;
               end if;
               if  ( clkin_period - ref2fb_dly_tmp + tpd ) < 0 ns or
                   ( clkin_period - ref2fb_dly_tmp ) < 0 ns then
                  assert false
                  report "Module EHXPLLB: Delay adjustment exceeds the clock period. Simulation Aborted!!!"
                  severity FAILURE;
               else 
                  ref2fb_dly <= ref2fb_dly_tmp;
                  fb_dly_rdy <= '1'; --071404
               end if;
            end if;
         ----------------------------------------------------

         when WAIT_NEW_CLKOP_FALL =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
            elsif falling_edge(new_clkop) then 
               use_new_clk_op <= '1';
               ------------------------------------------
               if new_clkos = '0' and new_clkok ='0' then
                  state <= WAIT_OLD_LOCK_FALL;
                  use_new_clk_os <= '1';
                  use_new_clk_ok <= '1';
               elsif (new_clkos = '0') then
                  state <= WAIT_NEW_CLKOK_FALL;
                  use_new_clk_os <= '1';
               elsif (new_clkok = '0') then
                  state <= WAIT_NEW_CLKOS_FALL;
                  use_new_clk_ok <= '1';
               else
                  state <= WAIT_NEW_CLKOS_CLKOK_FALL;
               end if;
              
            end if;

         ----------------------------------------------------
         when WAIT_NEW_CLKOS_CLKOK_FALL =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
            elsif falling_edge(new_clkos) or falling_edge (new_clkok) then
               if (new_clkos ='0' and new_clkok = '0') then
                  state <= WAIT_OLD_LOCK_FALL;
                  use_new_clk_os <= '1';
                  use_new_clk_ok <= '1';
               elsif (new_clkos = '0') then
                  state <= WAIT_NEW_CLKOK_FALL;
                  use_new_clk_os <= '1';
               elsif (new_clkok = '0') then
                  state <= WAIT_NEW_CLKOS_FALL;
                  use_new_clk_ok <= '1';
               end if;
            end if;

         ----------------------------------------------------
         when WAIT_NEW_CLKOS_FALL =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
            elsif falling_edge(new_clkos)  then
                  state <= WAIT_OLD_LOCK_FALL;
                  use_new_clk_os<= '1';
            end if;
         ----------------------------------------------------
         when WAIT_NEW_CLKOK_FALL =>
            if (old_lock'event and old_lock = '0') then
               state <= WAIT_OLD_LOCK_RISE;
               use_new_clk_op <= '0';
               use_new_clk_ok <= '0';
               use_new_clk_os <= '0';
               ref2fb_dly <= 0 ns;
               fb_dly_rdy <= '0'; -- 071404
            elsif falling_edge(new_clkok)  then
                  state <= WAIT_OLD_LOCK_FALL;
                  use_new_clk_ok<= '1';
            end if;
 
      end case;
   end process;
   
   ---------clkop_period <= clklock_half_period0 + clklock_half_period1 when old_lock = '1'
   ---------   else 10 ns;

   clkin_period <= clkin_half_period0 + clkin_half_period1 when old_lock = '1' -- 071304
      else 10 ns;

   --fb_adjust <= clkin_period - ref2fb_dly when (ref2fb_dly /= 0 ns) else 0 ns; --071304

------------------------------------------------------------------
-- CLK GENERATION
------------------------------------------------------------------

--clkop
process 

 variable hp1: time := 0 ns;
 variable hp0: time := 0 ns;
begin
   wait on old_lock;
   
   if (old_lock = '1') then
      --wait until rising_edge(fb_dly_rdy);
      --wait until rising_edge(CLKI_ipd);
      wait until rising_edge(fb_dly_rdy_r1); --081804
      wait for (clkin_period - ref2fb_dly + tpd);
      while (old_lock = '1') loop
         for op_i in 1 to mult_i  loop
           if (old_lock = '0') then
                exit;
           elsif (op_i = mult_i) then
               hp1 := clklock_half_period1 + clkop_err_1 ;
               hp0 := clklock_half_period0 + clkop_err_0  ;
           else
               hp1 := clklock_half_period1  ;
               hp0 := clklock_half_period0;
           end if;
           new_clkop <= not(new_clkop) and old_lock;
           wait for hp1;
           new_clkop <= not(new_clkop) and old_lock;
           wait for hp0;
         end loop;
      end loop;
   ------------------------------------------------
   elsif (old_lock = '0') then
      new_clkop <= '0';
   end if;
end process;

--clkos
process 

 variable hp1: time := 0 ns;
 variable hp0: time := 0 ns;
begin
   wait on old_lock;
   if (old_lock = '1') then
      --wait until rising_edge(fb_dly_rdy);
      --wait until rising_edge(CLKI_ipd);
      wait until rising_edge(fb_dly_rdy_r1); --081804
      wait for (clkin_period - ref2fb_dly + tpd + phase_shift);
      while (old_lock = '1') loop
        for os_i in 1 to mult_i  loop
          if (old_lock = '0') then
             exit;
          elsif (os_i = mult_i) then
             hp1 := (clklock_half_period0 + clklock_half_period1 + 
                     clkop_err_0 + clkop_err_1) * duty_i/8;
             hp0 := (clklock_half_period0 + clklock_half_period1 + 
                     clkop_err_0 + clkop_err_1) - hp1;
          else 
             hp1 := (clklock_half_period0 + clklock_half_period1 ) * duty_i/8;
             hp0 := (clklock_half_period0 + clklock_half_period1 ) - hp1;            
          end if;

          new_clkos <= not(new_clkos) and old_lock;
          wait for  hp1;
          new_clkos <= not(new_clkos) and old_lock;
          wait for hp0;
          --os_i <= os_i + 1;
         end loop;
      end loop;
   ------------------------------------------------
   elsif (old_lock = '0') then
      new_clkos <= '0';
   end if;
end process;

--clkok
process 

 variable hp1: time := 0 ns;
 variable hp0: time := 0 ns;
 
begin
   wait on old_lock;  
   if (old_lock = '1') then
      --wait until rising_edge(fb_dly_rdy);
      --wait until rising_edge(CLKI_ipd);
      wait until rising_edge(fb_dly_rdy_r1); --081804
      wait for (clkin_period - ref2fb_dly + tpd);
      while (old_lock = '1') loop
        for ok_i in 1 to mult_i  loop
          if (old_lock = '0') then
             exit;
          elsif (ok_i = mult_i) then
             hp1 := (clklock_half_period1 + clkop_err_1)* secdiv_p;
             hp0 := (clklock_half_period0 + clkop_err_0)* secdiv_p;         
          else 
             hp1 := (clklock_half_period1 )* secdiv_p;
             hp0 := (clklock_half_period0 )* secdiv_p; 
          end if;
        
          new_clkok <= not(new_clkok) and old_lock;
          wait for hp1;
          new_clkok <= not(new_clkok) and old_lock;
          wait for hp0;
        end loop;
      end loop;
   ------------------------------------------------
   elsif (old_lock = '0') then
      new_clkok <= '0';
   end if;
end process;


------------------------------------------------------------------

    clkref <= CLKI_ipd; --071404
    old_clkop <= clkref; --071404

   P100 : PROCESS (CLKFB)
   BEGIN
      IF (CLKFB'event and CLKFB = '1') THEN
         fb_count <= fb_count + 1;
         IF (fb_count = 3) THEN
            clk_first_time <= '0';
         END IF;
      END IF;
   END PROCESS;

    CLKOP1 <= new_clkop when fb_dly_rdy = '1' and old_lock = '1' else  old_clkop; --071404

   S11 : PROCESS (CLKOP1, rst_int)
   BEGIN
      IF (clk_first_time = '1') THEN
         CLKOP <= CLKOP1;
      ELSIF (rst_int = '1') THEN
         CLKOP <= '0';
      ELSIF (rst_int = '0') THEN
         CLKOP <= CLKOP1;
      END IF;
   END PROCESS;


    old_clkos <= clkref;
    CLKOS1 <= new_clkos when fb_dly_rdy = '1' and old_lock = '1' else  old_clkos; --071404

   S12 : PROCESS (CLKOS1, rst_int)
   BEGIN
      IF (clk_first_time = '1') THEN
         CLKOS <= CLKOS1;
      ELSIF (rst_int = '1') THEN
         CLKOS <= '0';
      ELSIF (rst_int = '0') THEN
         CLKOS <= CLKOS1;
      END IF;
   END PROCESS;

    old_clkok <= SEC_OUT_plus_delay and not RST_int;
    CLKOK <= new_clkok when fb_dly_rdy = '1' and old_lock = '1' else  '0'; --071404


    old_lock <= PLL_LOCK_plus and not RST_int when tpd >= 0 ns else
                PLL_LOCK_minus and  not RST_int;
    
    process (CLKI_ipd) --071404
    begin
       if rising_edge (CLKI_ipd) then
          fb_dly_rdy_r1 <=  fb_dly_rdy;
       end if;
    end process;
    LOCK <= old_lock and fb_dly_rdy_r1; --071404
   
-------------------------------------------------------------------------------------
   DDAOZR <= DDAIZR;
   DDAOLAG <= DDAILAG;
   DDA_DLY <= DDAIDEL2 & DDAIDEL1 & DDAIDEL0;
   DDAODEL0 <= DDAIDEL0;
   DDAODEL1 <= DDAIDEL1;
   DDAODEL2 <= DDAIDEL2;

   pll_dly_values <= pll_dly_user;

   tpd <= 0.25 ns * pll_dly_value;

---------------------------------------------------------------------------
-- RST
---------------------------------------------------------------------------
   process (old_lock)
   begin
      if (rising_edge(old_lock)) then
         rst_pause <= (clklock_half_period0 + clklock_half_period1) * secdiv_p;
      end if;
   
   end process;
  
   RST_int_o <= RST_ipd WHEN (RST_ipd = '0' or RST_ipd = '1') else
                  '0'; --081504

   process  --081504
   begin
      wait until rising_edge (RST_int_o);
      --wait until rising_edge(CLKI_ipd);
      RST_int_o2 <= '1';
      wait for rst_pause;
      wait until rising_edge(CLKI_ipd);
      RST_int_o2 <= '0';
   end process;

   RST_int <= RST_int_o or RST_int_o2;
      
      
      
          
   WireDelay : block
   begin
   VitalWireDelay (CLKI_ipd, CLKI, tipd_CLKI);
   VitalWireDelay (RST_ipd, RST, tipd_RST);
   end block;

static_dynamic : process(pll_dly_values,pll_dly_valued)
begin

      if (DELAY_CNTL = "STATIC") then
         pll_dly_value <= pll_dly_values;
      elsif (DELAY_CNTL = "DYNAMIC") then
         pll_dly_value <= pll_dly_valued;
      end if;
end process;

----------------------------------------------------------------------------
edge_count: PROCESS
     VARIABLE input_cycle : REAL;
     VARIABLE real_cycle : REAL;
     VARIABLE clkop_period0 : TIME;
     VARIABLE clkop_period1 : TIME;
BEGIN


   if (DDAMODE = '0') then
      pll_dly_valued <= pll_dly_user;
   elsif (DDAMODE = '1') then
      if (DDAIZR = '1') then
         pll_dly_valued <= 0;
      elsif (DDAIZR = '0') then
         if (DDAILAG = '1') then
             case DDA_DLY is
                 when "111"    => pll_dly_valued <= -8;
                 when "110"    => pll_dly_valued <= -7;
                 when "101"    => pll_dly_valued <= -6;
                 when "100"    => pll_dly_valued <= -5;
                 when "011"    => pll_dly_valued <= -4;
                 when "010"    => pll_dly_valued <= -3;
                 when "001"    => pll_dly_valued <= -2;
                 when "000"    => pll_dly_valued <= -1;
                 when others   => pll_dly_valued <= 0;
             end case;
         elsif (DDAILAG = '0') then
             case DDA_DLY is
                 when "111"    => pll_dly_valued <= 8;
                 when "110"    => pll_dly_valued <= 7;
                 when "101"    => pll_dly_valued <= 6;
                 when "100"    => pll_dly_valued <= 5;
                 when "011"    => pll_dly_valued <= 4;
                 when "010"    => pll_dly_valued <= 3;
                 when "001"    => pll_dly_valued <= 2;
                 when "000"    => pll_dly_valued <= 1;
                 when others   => pll_dly_valued <= 0;
             end case;
         end if;
      end if;
   end if;

   case phase_i is
       when 0      => phase_shift_value <= 0;
       when 45     => phase_shift_value <= 1;
       when 90     => phase_shift_value <= 2;
       when 135    => phase_shift_value <= 3;
       when 180    => phase_shift_value <= 4;
       when 225    => phase_shift_value <= 5;
       when 270    => phase_shift_value <= 6;
       when 315    => phase_shift_value <= 7;
       when others => phase_shift_value <= 0;
   end case;

        clklock_half_period <= (clklock_half_period0 + clklock_half_period1)/2;
        clklock_period <= clklock_half_period * 2;
        phase_shift <= (clklock_half_period0 + clklock_half_period1) * phase_shift_value/8;
        clkp_half_period1 <= (clklock_half_period0 + clklock_half_period1) * duty_i/8;
        clkp_half_period0 <= (clklock_half_period0 + clklock_half_period1) * (8 - duty_i)/8;

  WAIT UNTIL (CLKI_ipd'EVENT AND CLKI_ipd='1');
     clklock_rising_edge_count <= clklock_rising_edge_count +1;	   
   --  IF clklock_rising_edge_count = 0 THEN
        clklock_last_rising_edge <= NOW;	
	start_inclk <= CLKI_ipd;
   --  ELSE
   --  IF clklock_rising_edge_count = 2 THEN
       --clklock_half_period0 <= (NOW - clklock_last_falling_edge)/clockboost;
       clkop_period0 := (NOW - clklock_last_falling_edge) *div_r/mult_r; --081504
       clklock_half_period0 <= clkop_period0;
       clkop_err_0 <= (NOW - clklock_last_falling_edge) *div_r -
                      clkop_period0 * mult_r;

       clkin_half_period0 <= (NOW - clklock_last_falling_edge) ; --071304

	input_cycle := 1000.0 / input_frequency;
	real_cycle := REAL( (NOW - clklock_last_rising_edge) / 1 ns);
	IF ( real_cycle < 0.9 * input_cycle OR
	     real_cycle > 1.1 * input_cycle ) THEN
  	      	ASSERT TRUE 
  		REPORT " Input_Frequency Violation "
  		SEVERITY WARNING;
  		clklock_lock <= FALSE;
        END IF;
   --  elsif clklock_rising_edge_count = 2 THEN
        clklock_half_period_minus_dly0 <= (NOW - clklock_last_falling_edge) + tpd;
        secd_delay_minus0 <= (NOW - clklock_last_falling_edge) + tpd;


  -- END IF;
  --   END IF;
 
  WAIT UNTIL (CLKI_ipd'EVENT AND CLKI_ipd='0'); 
     clklock_falling_edge_count <= clklock_falling_edge_count +1; 	
   --  IF clklock_falling_edge_count = 0 THEN	
	clklock_last_falling_edge <= NOW;

	--clklock_half_period1 <= (NOW - clklock_last_rising_edge)/clockboost; 
       clkop_period1 := (NOW - clklock_last_rising_edge) *div_r/mult_r; --081504
       clklock_half_period1 <= clkop_period1;
       clkop_err_1 <= (NOW - clklock_last_rising_edge) *div_r -
                      clkop_period1 * mult_r;
                      
        clkin_half_period1 <= (NOW - clklock_last_rising_edge) ; --071304

       IF clklock_falling_edge_count = 2 THEN
        clklock_half_period_minus_dly1 <= (NOW - clklock_last_rising_edge) + tpd;
        secd_delay_minus1 <= (NOW - clklock_last_rising_edge) + tpd;

     END IF;
END PROCESS edge_count;

-------------------------------------------------------------------------------
ddy_change_r: PROCESS (clklock_rising_edge_count)
begin
     tpd_r1 <= tpd;
     tpd_r2 <= tpd_r1;
     tpd_r3 <= tpd_r2;
     tpd_r4 <= tpd_r3;
end process;

ddy_change_f: PROCESS (clklock_falling_edge_count)
begin
     tpd_f1 <= tpd;
     tpd_f2 <= tpd_f1;
     tpd_f3 <= tpd_f2;
     tpd_f4 <= tpd_f3;
end process;

--toggle: PROCESS (clklock_rising_edge_count)
toggle: PROCESS 
BEGIN
     WAIT ON clklock_rising_edge_count;
     if (RST_int = '1' or clk_lock = '0') then
        clock_count <= 0;
     elsif (tpd_r1 /= tpd_r4) then
        clock_count <= 0;
     elsif clklock_rising_edge_count > lock_cyc + 1 and RST_int = '0' THEN
        if(clockboost >1.0) then
	   FOR i IN 1 TO integer(2.0*clockboost) LOOP 	       
		clock_count <= clock_count + 1;
		WAIT FOR clklock_half_period;
	   END LOOP;
        else  
		clock_count <= clock_count + 1;
		WAIT FOR (clklock_half_period);
        end if;
     ELSE
	clock_count <= 0;
     END IF;
END PROCESS toggle;

toggle_0: PROCESS
BEGIN
     WAIT ON clklock_falling_edge_count;
     if (RST_int = '1' or clk_lock = '0') then
        clock_f_count <= 0;
     elsif clklock_falling_edge_count > lock_cyc + 1 and RST_int = '0' THEN
        if(clockboost >1.0) then
	   FOR i IN 1 TO integer(2.0*clockboost) LOOP 	       
		clock_f_count <= clock_f_count + 1;
		WAIT FOR clklock_half_period;
	   END LOOP;
        else  
		clock_f_count <= clock_f_count + 1;
		WAIT FOR (clklock_half_period);
        end if;
     ELSE
	clock_f_count <= 0;
     END IF;
END PROCESS toggle_0;

lock_detect : process (CLKI_ipd,tpd_r1,tpd_r2,clklock_half_period)
begin
  if (CLKI_ipd'event and CLKI_ipd = '1') THEN
    clklock_period_c1 <= clklock_period_c2;
    clklock_period_c2 <= clklock_period_c3;
    clklock_period_c3 <= clklock_half_period;
    if (clklock_period_c1 > 0 ps) then
        if (clklock_period_c1 = clklock_period_c3) then
            clk_lock_o <= '1'; --071404
        else
             if (clklock_falling_edge_count >5) then 
                clk_lock_o <= '0'; --071404
             end if;
        end if;
    end if;
    if (tpd_r1 /= tpd_r2) then
            clk_lock_o <= '0'; --071404
    end if;
  end if;
end process;


process  --081504
begin
   wait until falling_edge (clk_lock_o);
   --wait until rising_edge(CLKI_ipd);
   clk_lock_o2 <= '0';
     wait for rst_pause;
   wait until rising_edge(CLKI_ipd);
   clk_lock_o2 <= '1';
end process;

clk_lock <= clk_lock_o and clk_lock_o2;

gen_pll_lock_plus:process( clock_count, RST_int, clk_lock)
begin
     if (RST_int = '1' or clk_lock = '0') then
          PLL_LOCK_plus <= '0';
     elsif (clock_count=1) then
          PLL_LOCK_plus <= '1';
     end if;
end process;

gen_pll_lock_minus:process ( clock_f_count, RST_int, clk_lock)
begin
     if (RST_int = '1' or clk_lock = '0') then
          PLL_LOCK_minus <= '0';
     elsif (clock_f_count=1) then
          PLL_LOCK_minus <= '1';
     end if;
end process;

process(clock_count, tpd, RST_int, clk_lock)
begin 
  if( RST_int ='1') then
    CLK_OUT_sig_d_start <='0';
    SEC_OUT_sig_d_start <='0';
  elsif(clk_lock = '0') then
    CLK_OUT_sig_d_start <='0';
    SEC_OUT_sig_d_start <='0';
  elsif(clock_count = 1 and tpd >= 0 ns) then
    CLK_OUT_sig_d_start <='1' after tpd;
    SEC_OUT_sig_d_start <='1' after tpd;
  end if;
end process;

process 
begin
   wait on CLK_OUT_sig_d_start; 
   while (CLK_OUT_sig_d_start = '1') LOOP
      wait for clklock_half_period1;
      CLK_OUT_sig_d_not <= not CLK_OUT_sig_d_not;
      wait for clklock_half_period0;
      CLK_OUT_sig_d_not <= not CLK_OUT_sig_d_not;
   END LOOP;
end process;


process
begin
   wait on CLK_OUT_start;
   while (CLK_OUT_start = '1') LOOP
     wait for clklock_half_period1;
      CLK_OUT_sig_3d_not <= not CLK_OUT_sig_3d_not;
     wait for clklock_half_period0;
      CLK_OUT_sig_3d_not <= not CLK_OUT_sig_3d_not ;
     END LOOP;
end process;

process
begin
   wait on SEC_OUT_sig_d_start;
   while (SEC_OUT_sig_d_start = '1') LOOP
     wait for clklock_half_period1 * secdiv_p;
   SEC_OUT_sig_d_not <= not SEC_OUT_sig_d_not;
     wait for clklock_half_period0 * secdiv_p;
   SEC_OUT_sig_d_not <= not SEC_OUT_sig_d_not ;
   end LOOP;
end process;


process(clock_f_count,RST_int,clk_lock)
begin
--  wait until clklock_falling_edge_count >= lock_cyc + 1 and RST_int = '0';
    if (RST_int = '1') then 
      SEC_OUT_start <= '0';
      CLK_OUT_start <= '0';
      CLKP_OUT_start <= '0';
    elsif (clk_lock= '0') then
      SEC_OUT_start <= '0';
      CLK_OUT_start <= '0';
      CLKP_OUT_start <= '0';
    elsif (clock_f_count = 1) then 
      SEC_OUT_start <= '1' after  clklock_half_period_minus_dly0;
      CLK_OUT_start <= '1' after  clklock_half_period_minus_dly0;
      CLKP_OUT_start <= '1' after clklock_half_period_minus_dly0+phase_shift;
    end if;
end process;

process
begin
   wait on SEC_OUT_start; 
   while (SEC_OUT_start = '1') LOOP
     wait for clklock_half_period1 * secdiv_p;
      SEC_OUT_sig_3d_not <= not SEC_OUT_sig_3d_not;
     wait for clklock_half_period0 * secdiv_p;
      SEC_OUT_sig_3d_not <= not SEC_OUT_sig_3d_not ;
     END LOOP;
end process;

--------Implement CLKOS
process(clock_count, tpd, phase_shift, RST_int, clk_lock)
begin 
 --   wait until clock_count = 1;
 --   wait for phase_shift;
  if( RST_int ='1') then
    CLKP_OUT_sig_d_start <='0';
  elsif(clk_lock = '0') then
    CLKP_OUT_sig_d_start <='0';
  elsif (clock_count = 1 and tpd >= 0 ns) then
    CLKP_OUT_sig_d_start <='1' after (phase_shift + tpd);
  end if;
end process;

process
begin
   wait on CLKP_OUT_sig_d_start;
   while (CLKP_OUT_sig_d_start = '1') LOOP
     wait for clkp_half_period1;
   CLKP_OUT_sig_d_not <= not CLKP_OUT_sig_d_not;
     wait for clkp_half_period0;
   CLKP_OUT_sig_d_not <= not CLKP_OUT_sig_d_not ;
   END LOOP;
end process;

process
begin
   wait on CLKP_OUT_start;
   while ( CLKP_OUT_start = '1') LOOP
     wait for clkp_half_period1;
      CLKP_OUT_sig_3d_not <= not CLKP_OUT_sig_3d_not;
     wait for clkp_half_period0;
      CLKP_OUT_sig_3d_not <= not CLKP_OUT_sig_3d_not ;
     END LOOP;
end process;


    CLK_OUT_sig_d <= CLK_OUT_sig_d_start and not CLK_OUT_sig_d_not; 
    CLK_OUT_sig_3d <= CLK_OUT_start and not CLK_OUT_sig_3d_not; 

    CLKP_OUT_sig_d <= CLKP_OUT_sig_d_start and not CLKP_OUT_sig_d_not; 
    CLKP_OUT_sig_3d <= CLKP_OUT_start and not CLKP_OUT_sig_3d_not; 

    SEC_OUT_sig_d <= SEC_OUT_sig_d_start and not SEC_OUT_sig_d_not; 
    SEC_OUT_sig_3d <= SEC_OUT_start and not SEC_OUT_sig_3d_not; 


    CLK_OUT_plus_delay <= CLK_OUT_sig_d when tpd >= 0 ns else
                          CLK_OUT_sig_3d; 

    CLKP_OUT_plus_delay <= CLKP_OUT_sig_d when tpd >= 0 ns else
                          CLKP_OUT_sig_3d; 

    SEC_OUT_plus_delay <= SEC_OUT_sig_d  when tpd >= 0 ns else
                          SEC_OUT_sig_3d; 

    LOCK_int1 <= PLL_LOCK_plus and not RST_int when tpd >= 0 ns else
                PLL_LOCK_minus and  not RST_int;

end V;

configuration CFG_GENERIC_PLLB_V of GENERIC_PLLB is 
        for V
        end for; 
end CFG_GENERIC_PLLB_V;




--**********************************************************************
----- VITAL model for cell EPLLB -----
--**********************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.VITAL_Timing.all;
library ec;
use ec.components.all;
-- entity declaration --
entity EPLLB is
   generic(
      FIN  : string  := "100.0";
      CLKI_DIV      : string  := "1";
      CLKOP_DIV     : string  := "1";
      CLKFB_DIV     : string  := "1";
      FDEL          : string  := "1";
      FB_MODE       : string  := "CLOCKTREE";
      WAKE_ON_LOCK  : string  := "off";
      lock_cyc : integer := 2;
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;
      tpd_CLKI_CLKOP :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_CLKI    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CLKFB   :	VitalDelayType01 := (0.000 ns, 0.000 ns)
   );
   port(
      CLKI            : in    STD_ULOGIC;
      RST             : in    STD_ULOGIC;
      CLKFB           : in    STD_ULOGIC;
      CLKOP           : out   STD_ULOGIC;
      LOCK            : out   STD_ULOGIC
   );
--attribute VITAL_LEVEL0 of EPLLB : entity is FALSE;
end EPLLB;

-- architecture body --

architecture V of EPLLB is
  attribute VITAL_LEVEL1 of V : architecture is FALSE;
  
  ---------------------------------------------------------------------
  --  Component Declaration
  ---------------------------------------------------------------------
  component GENERIC_PLLB 
   generic(
      FIN             : string  := "100.0";
      CLKI_DIV        : string  := "1";
      CLKOP_DIV       : string  := "1";
      CLKFB_DIV       : string  := "1";
      FDEL            : string  := "1";
      FB_MODE         : string  := "CLOCKTREE";
      CLKOK_DIV       : string  := "2";
      WAKE_ON_LOCK    : string  := "off";
      DELAY_CNTL      : string  := "STATIC";
      PHASEADJ        : string  := "0";
      DUTY            : string  := "4";

      lock_cyc : integer := 2;
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;
      tpd_RST_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOP :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_CLKI    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CLKFB   :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_RST   :	VitalDelayType01 := (0.000 ns, 0.000 ns)

      );

   port(
      CLKI            : in    STD_ULOGIC;
      CLKFB           : in    STD_ULOGIC;
      RST             : in    STD_ULOGIC := '0';

      DDAMODE           : in    STD_ULOGIC;
      DDAIZR            : in    STD_ULOGIC;
      DDAILAG           : in    STD_ULOGIC;
      DDAIDEL0          : in    STD_ULOGIC;
      DDAIDEL1          : in    STD_ULOGIC;
      DDAIDEL2          : in    STD_ULOGIC;

      CLKOP             : out   STD_ULOGIC;
      CLKOS             : out   STD_ULOGIC;
      CLKOK             : out   STD_ULOGIC;
      LOCK              : out   STD_ULOGIC;

      DDAOZR            : out   STD_ULOGIC;
      DDAOLAG           : out   STD_ULOGIC;
      DDAODEL0          : out    STD_ULOGIC;
      DDAODEL1          : out    STD_ULOGIC;
      DDAODEL2          : out    STD_ULOGIC
);
end component;
 
  signal open1,open2,open3,open4,open5,open6,open7 : std_logic;
  signal gnd_sig : std_logic;

begin 
-----------------------------------------------------------------------
    gnd_sig <= '0';

GENERIC_PLLB_u1: GENERIC_PLLB


   generic map (

      FIN  =>  FIN,
      CLKI_DIV => CLKI_DIV ,
      CLKOP_DIV  => "1",
      CLKFB_DIV => CLKFB_DIV ,
      FDEL => FDEL,
      FB_MODE => FB_MODE,
      CLKOK_DIV   => "2",
      WAKE_ON_LOCK  => WAKE_ON_LOCK,
      DELAY_CNTL => "STATIC",
      PHASEADJ => "0",
      DUTY => "4",
      lock_cyc => lock_cyc,
      TimingChecksOn =>TimingChecksOn,
      InstancePath => InstancePath,
      Xon => Xon,
      MsgOn =>MsgOn,
      tpd_RST_LOCK => (0.0 ns, 0.0 ns),
      tpd_CLKI_CLKOP => tpd_CLKI_CLKOP,
      tpd_CLKI_LOCK => (0.0 ns, 0.0 ns),
      tpd_CLKI_CLKOK => tpd_CLKI_LOCK,
      tipd_CLKI => tipd_CLKI,
      tipd_CLKFB => tipd_CLKFB,
      tipd_RST => (0.000 ns, 0.000 ns)
   )
   
   port map(
      CLKI =>  CLKI,
      CLKFB => CLKFB,
      RST => RST,

      DDAMODE => gnd_sig,
      DDAIZR => gnd_sig,
      DDAILAG => gnd_sig,
      DDAIDEL0 => gnd_sig,
      DDAIDEL1 => gnd_sig,
      DDAIDEL2 => gnd_sig,

      CLKOP => CLKOP,
      CLKOS  => open1,
      CLKOK  => open2,
      LOCK => LOCK,

      DDAOZR => open3,
      DDAOLAG => open4,
      DDAODEL0  => open5,
      DDAODEL1  => open6,
      DDAODEL2 => open7
    );
    
end V;

configuration CFG_EPLLB_V of EPLLB is 
        for V
        end for; 
end CFG_EPLLB_V;


--******************************************************************
----- VITAL model for cell EHXPLLB -----
--******************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use IEEE.VITAL_Timing.all;
library ec;
use ec.components.all;

-- entity declaration --
entity EHXPLLB is
   generic(
   
     
      FIN  : string  := "100.0";
      CLKI_DIV      : string  := "1";
      CLKOP_DIV     : string  := "1";
      CLKFB_DIV     : string  := "1";
      FDEL  : string  := "1";
      FB_MODE  : string  := "CLOCKTREE";
      CLKOK_DIV   : string   := "2";
      WAKE_ON_LOCK  : string  := "off";
      DELAY_CNTL    : string  := "STATIC";
      PHASEADJ       :  string  := "0";
      DUTY        :  string  := "4";
      lock_cyc : integer := 2;
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;
      tpd_RST_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOP :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_CLKI    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CLKFB   :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_RST   :	VitalDelayType01 := (0.000 ns, 0.000 ns)
   );

   port(
      CLKI            : in    STD_ULOGIC;
      CLKFB           : in    STD_ULOGIC;
      RST           : in    STD_ULOGIC := '0';

      DDAMODE            : in    STD_ULOGIC;
      DDAIZR            : in    STD_ULOGIC;
      DDAILAG           : in    STD_ULOGIC;
      DDAIDEL0          : in    STD_ULOGIC;
      DDAIDEL1          : in    STD_ULOGIC;
      DDAIDEL2          : in    STD_ULOGIC;

      CLKOP           : out   STD_ULOGIC;
      CLKOS          : out   STD_ULOGIC;
      CLKOK           : out   STD_ULOGIC;
      LOCK          : out   STD_ULOGIC;

      DDAOZR           : out   STD_ULOGIC;
      DDAOLAG          : out   STD_ULOGIC;
      DDAODEL0         : out   STD_ULOGIC;
      DDAODEL1         : out   STD_ULOGIC;
      DDAODEL2         : out   STD_ULOGIC
);
--attribute VITAL_LEVEL0 of EHXPLLB : entity is FALSE;
end EHXPLLB;

-- architecture body --

architecture V of EHXPLLB is
  attribute VITAL_LEVEL1 of V : architecture is FALSE;

  ---------------------------------------------------------------------
  --  Component Declaration
  ---------------------------------------------------------------------
  component GENERIC_PLLB 
   generic(
      FIN             : string  := "100.0";
      CLKI_DIV        : string  := "1";
      CLKOP_DIV       : string  := "1";
      CLKFB_DIV       : string  := "1";
      FDEL            : string  := "1";
      FB_MODE         : string  := "CLOCKTREE";
      CLKOK_DIV       : string  := "2";
      WAKE_ON_LOCK    : string  := "off";
      DELAY_CNTL      : string  := "STATIC";
      PHASEADJ        : string  := "0";
      DUTY            : string  := "4";

      lock_cyc : integer := 2;
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;
      tpd_RST_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOP :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_LOCK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tpd_CLKI_CLKOK :	VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_CLKI    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CLKFB   :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_RST   :	VitalDelayType01 := (0.000 ns, 0.000 ns)

      );

   port(
      CLKI            : in    STD_ULOGIC;
      CLKFB           : in    STD_ULOGIC;
      RST             : in    STD_ULOGIC := '0';

      DDAMODE           : in    STD_ULOGIC;
      DDAIZR            : in    STD_ULOGIC;
      DDAILAG           : in    STD_ULOGIC;
      DDAIDEL0          : in    STD_ULOGIC;
      DDAIDEL1          : in    STD_ULOGIC;
      DDAIDEL2          : in    STD_ULOGIC;

      CLKOP             : out   STD_ULOGIC;
      CLKOS             : out   STD_ULOGIC;
      CLKOK             : out   STD_ULOGIC;
      LOCK              : out   STD_ULOGIC;

      DDAOZR            : out   STD_ULOGIC;
      DDAOLAG           : out   STD_ULOGIC;
      DDAODEL0          : out    STD_ULOGIC;
      DDAODEL1          : out    STD_ULOGIC;
      DDAODEL2          : out    STD_ULOGIC
);
end component;
 

begin 
-----------------------------------------------------------------------
GENERIC_PLLB_u2: GENERIC_PLLB

   generic map (

      FIN  =>  FIN,
      CLKI_DIV => CLKI_DIV ,
      CLKOP_DIV  => CLKOP_DIV,
      CLKFB_DIV => CLKFB_DIV ,
      FDEL => FDEL,
      FB_MODE => FB_MODE,
      CLKOK_DIV   => CLKOK_DIV,
      WAKE_ON_LOCK  => WAKE_ON_LOCK,
      DELAY_CNTL => DELAY_CNTL,
      PHASEADJ => PHASEADJ,
      DUTY => DUTY,
      lock_cyc => lock_cyc,
      TimingChecksOn =>TimingChecksOn,
      InstancePath => InstancePath,
      Xon => Xon,
      MsgOn =>MsgOn,
      tpd_RST_LOCK => tpd_RST_LOCK,
      tpd_CLKI_CLKOP => tpd_CLKI_CLKOP,
      tpd_CLKI_LOCK => tpd_CLKI_LOCK,
      tpd_CLKI_CLKOK => tpd_CLKI_LOCK,
      tipd_CLKI => tipd_CLKI,
      tipd_CLKFB => tipd_CLKFB,
      tipd_RST => tipd_RST
   )
   
   port map(
      CLKI =>  CLKI,
      CLKFB => CLKFB,
      RST => RST,

      DDAMODE => DDAMODE,
      DDAIZR => DDAIZR,
      DDAILAG => DDAILAG,
      DDAIDEL0 => DDAIDEL0,
      DDAIDEL1 => DDAIDEL1,
      DDAIDEL2 => DDAIDEL2,

      CLKOP => CLKOP,
      CLKOS  => CLKOS,
      CLKOK  => CLKOK,
      LOCK => LOCK,

      DDAOZR => DDAOZR,
      DDAOLAG => DDAOLAG,
      DDAODEL0  => DDAODEL0,
      DDAODEL1  => DDAODEL1,
      DDAODEL2 => DDAODEL2
    );
    
end V;

configuration CFG_EHXPLLB_V of EHXPLLB is 
        for V
        end for; 
end CFG_EHXPLLB_V;





--*********************************************************************
----- CELL MULT2 -----
--*********************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;


-- entity declaration --
entity MULT2 is
   generic(
      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := False;
      MsgOn: Boolean := False;
      tpd_A0_P0                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A1_P0                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A2_P1                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A3_P1                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B0_P0                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B1_P0                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B2_P1                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B3_P1                      :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_CI_P0                     :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_CI_P1                     :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A0_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A1_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A2_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_A3_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B0_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B1_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B2_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_B3_CO                    :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tpd_CI_CO                   :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A0                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A1                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A2                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A3                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B0                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B1                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B2                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B3                        :	VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CI                       :	VitalDelayType01 := (0.000 ns, 0.000 ns));

   port(
      A0                             :	in    STD_ULOGIC;
      A1                             :	in    STD_ULOGIC;
      A2                             :	in    STD_ULOGIC;
      A3                             :	in    STD_ULOGIC;
      B0                             :	in    STD_ULOGIC;
      B1                             :	in    STD_ULOGIC;
      B2                             :	in    STD_ULOGIC;
      B3                             :	in    STD_ULOGIC;
      CI                            :	in    STD_ULOGIC;
      P0                             :	out   STD_ULOGIC;
      P1                             :	out   STD_ULOGIC;
      CO                           :	out   STD_ULOGIC);
attribute VITAL_LEVEL0 of MULT2 : entity is TRUE;
end MULT2;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture V of MULT2 is
   attribute VITAL_LEVEL1 of V : architecture is TRUE;

   SIGNAL A0_ipd	 : STD_ULOGIC := 'X';
   SIGNAL A1_ipd	 : STD_ULOGIC := 'X';
   SIGNAL A2_ipd	 : STD_ULOGIC := 'X';
   SIGNAL A3_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B0_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B1_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B2_ipd	 : STD_ULOGIC := 'X';
   SIGNAL B3_ipd	 : STD_ULOGIC := 'X';
   SIGNAL CI_ipd	 : STD_ULOGIC := 'X';

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (A0_ipd, A0, tipd_A0);
   VitalWireDelay (A1_ipd, A1, tipd_A1);
   VitalWireDelay (A2_ipd, A2, tipd_A2);
   VitalWireDelay (A3_ipd, A3, tipd_A3);
   VitalWireDelay (B0_ipd, B0, tipd_B0);
   VitalWireDelay (B1_ipd, B1, tipd_B1);
   VitalWireDelay (B2_ipd, B2, tipd_B2);
   VitalWireDelay (B3_ipd, B3, tipd_B3);
   VitalWireDelay (CI_ipd, CI, tipd_CI);
   end block;
   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : process (A0_ipd, B0_ipd, A1_ipd, B1_ipd, A2_ipd, B2_ipd, A3_ipd, B3_ipd, CI_ipd)


   -- functionality results
   VARIABLE Results : STD_LOGIC_VECTOR(1 to 3) := (others => 'X');
   ALIAS P0_zd : STD_LOGIC is Results(1);
   ALIAS P1_zd : STD_LOGIC is Results(2);
   ALIAS CO_zd : STD_LOGIC is Results(3);

   -- output glitch detection variables
   VARIABLE P0_GlitchData	: VitalGlitchDataType;
   VARIABLE P1_GlitchData	: VitalGlitchDataType;
   VARIABLE CO_GlitchData	: VitalGlitchDataType;
   VARIABLE C_int         : STD_LOGIC := 'X';

   begin

      -------------------------
      --  Functionality Section
      -------------------------
      P0_zd := ((B0_ipd) AND (A0_ipd)) XOR ((B1_ipd) AND (A1_ipd)) XOR (CI_ipd);
      C_int :=
       (A0_ipd AND B0_ipd AND A1_ipd AND B1_ipd) OR (A0_ipd AND B0_ipd AND CI_ipd) OR (A1_ipd AND B1_ipd AND CI_ipd);

      P1_zd := ((B2_ipd) AND (A2_ipd)) XOR ((B3_ipd) AND (A3_ipd)) XOR (C_int);
      CO_zd :=
       (A2_ipd AND B2_ipd AND A3_ipd AND B3_ipd) OR (A2_ipd AND B2_ipd AND C_int) OR (A3_ipd AND B3_ipd AND C_int);

      ----------------------
      --  Path Delay Section
      ----------------------
      VitalPathDelay01 (
       OutSignal => P0,
       GlitchData => P0_GlitchData,
       OutSignalName => "P0",
       OutTemp => P0_zd,
       Paths => (0 => (A0_ipd'last_event, tpd_A0_P0, TRUE),
		 1 => (A1_ipd'last_event, tpd_A1_P0, TRUE),
                 2 => (B0_ipd'last_event, tpd_B0_P0, TRUE),
		 3 => (B1_ipd'last_event, tpd_B1_P0, TRUE),
                 4 => (CI_ipd'last_event, tpd_CI_P0, TRUE)),
       Mode => OnDetect,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

      VitalPathDelay01 (
       OutSignal => P1,
       GlitchData => P1_GlitchData,
       OutSignalName => "P1",
       OutTemp => P1_zd,
       Paths => (0 => (A2_ipd'last_event, tpd_A2_P1, TRUE),
		 1 => (A3_ipd'last_event, tpd_A3_P1, TRUE),
                 2 => (B2_ipd'last_event, tpd_B2_P1, TRUE),
		 3 => (B3_ipd'last_event, tpd_B3_P1, TRUE),
                 4 => (CI_ipd'last_event, tpd_CI_P1, TRUE)),
       Mode => OnDetect,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

      VitalPathDelay01 (
       OutSignal => CO,
       GlitchData => CO_GlitchData,
       OutSignalName => "CO",
       OutTemp => CO_zd,
       Paths => (0 => (A0_ipd'last_event, tpd_A0_CO, TRUE),
		 1 => (A1_ipd'last_event, tpd_A1_CO, TRUE),
		 2 => (A2_ipd'last_event, tpd_A2_CO, TRUE),
		 3 => (A3_ipd'last_event, tpd_A3_CO, TRUE),
                 4 => (B0_ipd'last_event, tpd_B0_CO, TRUE),
		 5 => (B1_ipd'last_event, tpd_B1_CO, TRUE),
		 6 => (B2_ipd'last_event, tpd_B2_CO, TRUE),
		 7 => (B3_ipd'last_event, tpd_B3_CO, TRUE),
                 8 => (CI_ipd'last_event, tpd_CI_CO, TRUE)),
       Mode => OnDetect,
       Xon => Xon,
       MsgOn => MsgOn,
       MsgSeverity => WARNING);

end process;

end V;

configuration CFG_MULT2_V of MULT2 is
   for V
   end for;
end CFG_MULT2_V;

--
----- cell iddrxb -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;

ENTITY iddrxb IS
    GENERIC (
        REGSET          : string  := "RESET";
        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath    : string := "iddrxb";
        -- propagation delays
        tpd_sclk_qa     : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_sclk_qb     : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_d_eclk_noedge_posedge    : VitalDelayType := 0.0 ns;
        thold_d_eclk_noedge_posedge     : VitalDelayType := 0.0 ns;
        tsetup_lsr_eclk_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_lsr_eclk_noedge_posedge   : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_d                  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ce                 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_lsr                : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_eclk               : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_sclk               : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ddrclkpol          : VitalDelayType01 := (0.0 ns, 0.0 ns);
        -- pulse width constraints
        tperiod_eclk            : VitalDelayType := 0.001 ns;
        tpw_eclk_posedge         : VitalDelayType := 0.001 ns;
        tpw_eclk_negedge         : VitalDelayType := 0.001 ns;
        tperiod_sclk             : VitalDelayType := 0.001 ns;
        tpw_sclk_posedge         : VitalDelayType := 0.001 ns;
        tpw_sclk_negedge         : VitalDelayType := 0.001 ns;
        tperiod_lsr             : VitalDelayType := 0.001 ns;
        tpw_lsr_posedge         : VitalDelayType := 0.001 ns;
        tpw_lsr_negedge         : VitalDelayType := 0.001 ns);

    PORT (
        d               : IN std_logic;
        ce              : IN std_logic;
        eclk            : IN std_logic;
        sclk            : IN std_logic;
        lsr             : IN std_logic;
        ddrclkpol       : IN std_logic;
        qa              : OUT std_logic;
        qb              : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF iddrxb : ENTITY IS TRUE;

END iddrxb ;

-- architecture body --
ARCHITECTURE v OF iddrxb IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

    SIGNAL d_ipd   : std_logic := '0';
    SIGNAL ce_ipd   : std_logic := '0';
    SIGNAL eclk_ipd : std_logic := '0';
    SIGNAL sclk_ipd : std_logic := '0';
    SIGNAL lsr_ipd : std_logic := '0';
    SIGNAL ddrclkpol_ipd : std_logic := '0';
    SIGNAL QP      : std_logic := '0';
    SIGNAL QN      : std_logic := '0';
    SIGNAL QP_n    : std_logic := '0';
    SIGNAL QPreg   : std_logic := '0';
    SIGNAL QNreg   : std_logic := '0';
    SIGNAL sclk_pol   : std_logic := '0';

BEGIN

   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(d_ipd, d, tipd_d);
       VitalWireDelay(ce_ipd, ce, tipd_ce);
       VitalWireDelay(eclk_ipd, eclk, tipd_eclk);
       VitalWireDelay(sclk_ipd, sclk, tipd_sclk);
       VitalWireDelay(lsr_ipd, lsr, tipd_lsr);
       VitalWireDelay(ddrclkpol_ipd, ddrclkpol, tipd_ddrclkpol);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------
   S1 : PROCESS (sclk_ipd, ddrclkpol_ipd)
   BEGIN
      IF (ddrclkpol_ipd = '1') THEN
         sclk_pol <= not sclk_ipd;
      ELSIF (ddrclkpol_ipd = '0') THEN
         sclk_pol <= sclk_ipd;
      END IF;
   END PROCESS;

   P1 : PROCESS (eclk_ipd)
   BEGIN
      IF (eclk_ipd = 'X') THEN
         IF (QP /= d_ipd) THEN
            QP <= 'X';
         END IF;
      ELSIF (eclk_ipd'event and eclk_ipd'last_value = '0' and eclk_ipd = '1') THEN
            QP <= d_ipd;
      END IF;
   END PROCESS;

   P2 : PROCESS (eclk_ipd)
   BEGIN
      IF (eclk_ipd = 'X') THEN
         IF (QP_n /= QP) THEN
            QP_n <= 'X';
         END IF;
         IF (QN /= d_ipd) THEN
            QN <= 'X';
         END IF;
      ELSIF (eclk_ipd'event and eclk_ipd'last_value = '1' and eclk_ipd = '0') THEN
         QP_n <= QP;
         QN <= d_ipd;
      END IF;
   END PROCESS;

   P3 : PROCESS (sclk_pol)
   BEGIN
      IF (sclk_pol = 'X') THEN
         IF (QPreg /= QP_n) THEN
            QPreg <= 'X';
         END IF;
         IF (QNreg /= QN) THEN
            QNreg <= 'X';
         END IF;
      ELSIF (sclk_pol'event and sclk_pol'last_value = '0' and sclk_pol = '1') THEN
         IF (lsr_ipd = '1') THEN
            IF (REGSET = "RESET") THEN
               QPreg <= '0';
               QNreg <= '0';
            ELSIF (REGSET = "SET") THEN
               QPreg <= '1';
               QNreg <= '1';
            END IF;
         ELSIF (lsr_ipd = '0') THEN
            QPreg <= QP_n;
            QNreg <= QN;
         END IF;
      END IF;
   END PROCESS;

   VitalBehavior : PROCESS (QPreg, QNreg)

   -- timing check results
   VARIABLE tviol_eclk   : X01 := '0';
   VARIABLE tviol_d     : X01 := '0';
   VARIABLE tviol_lsr   : X01 := '0';
   VARIABLE d_eclk_TimingDatash  : VitalTimingDataType;
   VARIABLE lsr_eclk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_eclk : VitalPeriodDataType;
   VARIABLE periodcheckinfo_sclk : VitalPeriodDataType;

   -- functionality results
   VARIABLE violation   : X01 := '0';
   VARIABLE results : std_logic_vector(1 to 2) := (others => 'X');
   ALIAS qa_zd          : std_ulogic IS results(1);
   ALIAS qb_zd          : std_ulogic IS results(2);
   -- output glitch detection VARIABLEs
   VARIABLE qa_GlitchData     : VitalGlitchDataType;
   VARIABLE qb_GlitchData     : VitalGlitchDataType;

   BEGIN

   ------------------------
   --  timing check section
   ------------------------

    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => d_ipd, TestSignalName => "d",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_d_eclk_noedge_posedge,
            SetupLow => tsetup_d_eclk_noedge_posedge,
            HoldHigh => thold_d_eclk_noedge_posedge,
            HoldLow => thold_d_eclk_noedge_posedge,
            CheckEnabled => TRUE,
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => d_eclk_timingdatash,
            Violation => tviol_d, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => lsr_ipd, TestSignalName => "lsr",
            RefSignal => eclk_ipd, RefSignalName => "eclk",
            SetupHigh => tsetup_lsr_eclk_noedge_posedge,
            SetupLow => tsetup_lsr_eclk_noedge_posedge,
            HoldHigh => thold_lsr_eclk_noedge_posedge,
            HoldLow => thold_lsr_eclk_noedge_posedge,
            CheckEnabled => TRUE,
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => lsr_eclk_timingdatash,
            Violation => tviol_lsr, MsgSeverity => warning);
    END IF;

    -----------------------------------
    -- functionality section.
    -----------------------------------
      qa_zd := VitalBUF(QPreg);
      qb_zd := VitalBUF(QNreg);

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => qa,
      OutSignalName => "qa",
      OutTemp => qa_zd,
      Paths => (0 => (inputchangetime => sclk_ipd'last_event,
                      pathdelay => tpd_sclk_qa,
                      pathcondition => TRUE)),
      GlitchData => qa_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
    VitalPathDelay01 (
      OutSignal => qb,
      OutSignalName => "qb",
      OutTemp => qb_zd,
      Paths => (0 => (inputchangetime => sclk_pol'last_event,
                      pathdelay => tpd_sclk_qb,
                      pathcondition => TRUE)),
      GlitchData => qb_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;

END v;



------CELL ODDRXB------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
USE ieee.vital_primitives.all;

-- entity declaration --
entity ODDRXB is
    GENERIC (
        REGSET          : string  := "RESET";
        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath    : string := "oddrxb";
        -- propagation delays
        tpd_clk_q       : VitalDelayType01 := (0.001 ns, 0.001 ns);
        -- setup and hold constraints
        tsetup_da_clk_noedge_posedge    : VitalDelayType := 0.0 ns;
        thold_da_clk_noedge_posedge     : VitalDelayType := 0.0 ns;
        tsetup_db_clk_noedge_posedge    : VitalDelayType := 0.0 ns;
        thold_db_clk_noedge_posedge     : VitalDelayType := 0.0 ns;
        tsetup_lsr_clk_noedge_posedge   : VitalDelayType := 0.0 ns;
        thold_lsr_clk_noedge_posedge    : VitalDelayType := 0.0 ns;
        -- input SIGNAL delays
        tipd_da                 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_db                 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_lsr                : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_clk                : VitalDelayType01 := (0.0 ns, 0.0 ns));

    port(
          da		:	in	STD_LOGIC;
          db		:	in	STD_LOGIC;
          clk	        :	in	STD_LOGIC;
          lsr	        :	in	STD_LOGIC;
          q		:	out	STD_LOGIC
        );

attribute VITAL_LEVEL0 of ODDRXB : entity is TRUE;
end ODDRXB;

-- architecture body --

architecture V of ODDRXB is
  attribute VITAL_LEVEL0 of V : architecture is TRUE;
    SIGNAL da_ipd    : std_logic := '0';
    SIGNAL db_ipd    : std_logic := '0';
    SIGNAL clk_ipd    : std_logic := '0';
    SIGNAL lsr_ipd  : std_logic := '0';
    SIGNAL QP       : std_logic := '0';
    SIGNAL QN       : std_logic := '0';

begin 
   ---------------------
   --  input path delays
   ---------------------
    WireDelay : BLOCK
    BEGIN
       VitalWireDelay(da_ipd, da, tipd_da);
       VitalWireDelay(db_ipd, db, tipd_db);
       VitalWireDelay(clk_ipd, clk, tipd_clk);
       VitalWireDelay(lsr_ipd, lsr, tipd_lsr);
    END BLOCK;

   --------------------
   --  behavior section
   --------------------

  P1: PROCESS(clk_ipd)
  BEGIN
     IF (clk_ipd = 'X') THEN
         IF (QN /= db_ipd) THEN
            QN <= 'X';
         END IF;
      ELSIF (clk_ipd'event and clk_ipd'last_value = '0' and clk_ipd = '1') THEN
         IF (lsr_ipd = '1') THEN
            IF (REGSET = "RESET") THEN
               QN <= '0';
            ELSIF (REGSET = "SET") THEN
               QN <= '1';
            END IF;
         ELSE
            QN <= db_ipd;
         END IF;
      END IF;
   END PROCESS;
 
  P2 : PROCESS(clk_ipd, da_ipd)
   begin
       if (clk_ipd = '0') then
         QP <= da_ipd;
       else
         QP <= QP;
       end if;
  end process;  

   VitalBehavior : PROCESS (clk_ipd, QP, QN)

   -- timing check results
   VARIABLE tviol_clk   : X01 := '0';
   VARIABLE tviol_da    : X01 := '0';
   VARIABLE tviol_db    : X01 := '0';
   VARIABLE tviol_lsr   : X01 := '0';
   VARIABLE da_clk_TimingDatash  : VitalTimingDataType;
   VARIABLE db_clk_TimingDatash  : VitalTimingDataType;
   VARIABLE lsr_clk_TimingDatash : VitalTimingDataType;
   VARIABLE periodcheckinfo_clk : VitalPeriodDataType;

   -- functionality results
   VARIABLE violation   : X01 := '0';
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS q_zd           : std_ulogic IS results(1);
   -- output glitch detection VARIABLEs
   VARIABLE q_GlitchData     : VitalGlitchDataType;


   BEGIN

   ------------------------
   --  timing check section
   ------------------------

    IF (TimingChecksOn) THEN
        VitalSetupHoldCheck (
            TestSignal => da_ipd, TestSignalName => "da",
            RefSignal => clk_ipd, RefSignalName => "clk",
            SetupHigh => tsetup_da_clk_noedge_posedge,
            SetupLow => tsetup_da_clk_noedge_posedge,
            HoldHigh => thold_da_clk_noedge_posedge,
            HoldLow => thold_da_clk_noedge_posedge,
            CheckEnabled => TRUE,
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => da_clk_timingdatash,
            Violation => tviol_da, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => db_ipd, TestSignalName => "db",
            RefSignal => clk_ipd, RefSignalName => "clk",
            SetupHigh => tsetup_db_clk_noedge_posedge,
            SetupLow => tsetup_db_clk_noedge_posedge,
            HoldHigh => thold_db_clk_noedge_posedge,
            HoldLow => thold_db_clk_noedge_posedge,
            CheckEnabled => TRUE,
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => db_clk_timingdatash,
            Violation => tviol_db, MsgSeverity => warning);
        VitalSetupHoldCheck (
            TestSignal => lsr_ipd, TestSignalName => "lsr",
            RefSignal => clk_ipd, RefSignalName => "clk",
            SetupHigh => tsetup_lsr_clk_noedge_posedge,
            SetupLow => tsetup_lsr_clk_noedge_posedge,
            HoldHigh => thold_lsr_clk_noedge_posedge,
            HoldLow => thold_lsr_clk_noedge_posedge,
            CheckEnabled => TRUE,
            RefTransition => '/', MsgOn => MsgOn, XOn => XOn,
            HeaderMsg => InstancePath, TimingData => lsr_clk_timingdatash,
            Violation => tviol_lsr, MsgSeverity => warning);
    END IF;

    -----------------------------------
    -- functionality section.
    -----------------------------------
      q_zd := vitalmux
                 (data => (QP, QN),
                  dselect => (0 => clk_ipd));

    -----------------------------------
    -- path delay section.
    -----------------------------------
    VitalPathDelay01 (
      OutSignal => q,
      OutSignalName => "q",
      OutTemp => q_zd,
      Paths => (0 => (inputchangetime => clk_ipd'last_event,
                      pathdelay => tpd_clk_q,
                      pathcondition => TRUE)),
      GlitchData => q_GlitchData,
      Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);

END PROCESS;

END v;

configuration CFG_ODDRXB_V of ODDRXB is
   for V
   end for;
end CFG_ODDRXB_V;


--*********************************************************************
------CELL DQSDLL------
--*********************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

-- entity declaration --
entity DQSDLL is
    generic(LOCK_CYC         : integer := 2;
	    DEL_ADJ          : string  := "PLUS";
            DEL_VAL          : string  := "0";
            LOCK_SENSITIVITY : string  := "LOW");
    port(
          CLK		:	in	STD_ULOGIC;
          RST	        :	in	STD_ULOGIC;
          UDDCNTL       :	in	STD_ULOGIC;
          LOCK		:	out	STD_ULOGIC;
          DQSDEL	:	out	STD_ULOGIC
        );

attribute VITAL_LEVEL0 of DQSDLL : entity is FALSE;
end DQSDLL;

-- architecture body --

architecture V of DQSDLL is
  attribute VITAL_LEVEL0 of V : architecture is FALSE;

  signal RST_int      :  std_logic;
  signal UDDCNTL_int  : std_logic;
  signal LOCK_int     : std_logic;
  signal DQSDEL_int   : std_logic;
  signal clkin_in     : std_logic;
  signal clk_rising_edge_count : integer := 0;

begin 

  clkin_in <= VitalBUF(CLK);
  RST_int  <= VitalBUF(RST);
  UDDCNTL_int <= VitalBUF(UDDCNTL);

  LOCK  <= VitalBUF(LOCK_int);
  DQSDEL <= VitalBUF(DQSDEL_int);
  
  process(clkin_in, RST_int)
  begin
    if (RST_int = '1') then
        clk_rising_edge_count <= 0;
    elsif (clkin_in'event and clkin_in = '1') then
        clk_rising_edge_count <= clk_rising_edge_count + 1;
    end if;
  end process;

  process(clk_rising_edge_count, RST_int)
  begin
    if (RST_int = '1') then
        LOCK_int <= '0';
    elsif (clk_rising_edge_count > LOCK_CYC) then
        LOCK_int <= '1';
    end if;
  end process;

  process(LOCK_int, UDDCNTL_int, RST_int)
  begin
    if (RST_int = '1') then
        DQSDEL_int <= '0';
    elsif (UDDCNTL_int = '1') then
        DQSDEL_int <= LOCK_int;
    else
        DQSDEL_int <= DQSDEL_int;
    end if;
  end process;
 
end V;

configuration CFG_DQSDLL_V of DQSDLL is
   for V
   end for;
end CFG_DQSDLL_V;

------cell dqsbufb------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.components.all;

-- entity declaration --
ENTITY dqsbufb IS
   GENERIC(
      DEL_ADJ         : String  := "PLUS";
      DEL_VAL         : String  := "0";
      TimingChecksOn  : boolean := TRUE;
      XOn             : boolean := FALSE;
      MsgOn           : boolean := TRUE;
      InstancePath    : string := "dqsbufb";
      tipd_dqsi       : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_clk        : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_read       : VitalDelayType01 := (0.0 ns, 0.0 ns);
      tipd_dqsdel     : VitalDelayType01 := (0.0 ns, 0.0 ns));

    PORT(
          dqsi		:	IN	std_logic;
          clk		:	IN	std_logic;
          read	        :	IN	std_logic;
          dqsdel        :	IN	std_logic;
          dqso		:	OUT	std_logic;
          ddrclkpol	:	OUT	std_logic;
          dqsc		:	OUT	std_logic;
          prmbdet	:	OUT	std_logic
        );

ATTRIBUTE vital_level0 OF dqsbufb : ENTITY IS TRUE;
END dqsbufb;

-- architecture body --

architecture V of DQSBUFB is
  ATTRIBUTE vital_level0 OF v : ARCHITECTURE IS TRUE;
---
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
---
  SIGNAL dqsi_ipd                 : std_logic := '0';
  SIGNAL clk_ipd                  : std_logic := '0';
  SIGNAL read_ipd                 : std_logic := '0';
  SIGNAL dqsdel_ipd               : std_logic := '0';
  SIGNAL quarter_period           : time := 0 ns;
  SIGNAL clk_last_rising_edge     : time := 0 ns;
  SIGNAL A, C                     : std_logic := '0';
  SIGNAL B, D, E                  : std_logic := '0';
  SIGNAL A_inv, C_inv                     : std_logic := '0';
  SIGNAL B_inv, D_inv, E_inv                  : std_logic := '0';
  SIGNAL DDRCLKPOL_int            : std_logic := '0';
  SIGNAL CLKP                     : std_logic := '0';
  SIGNAL DQSO_int                 : std_logic := '0';
  SIGNAL DQSC_int                 : std_logic := '0';
  SIGNAL DQSO_int1                : std_logic := '0';
  SIGNAL PRMBDET_int              : std_logic := '0';
  SIGNAL DQSO_int0                : std_logic := '0';
  SIGNAL DQSO_int2                : std_logic := '0';
  SIGNAL clk_rising_edge_count    : integer := 0;

begin 

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(dqsi_ipd, dqsi, tipd_dqsi);
   VitalWireDelay(clk_ipd, clk, tipd_clk);
   VitalWireDelay(read_ipd, read, tipd_read);
   VitalWireDelay(dqsdel_ipd, dqsdel, tipd_dqsdel);
   END BLOCK;

   --------------------
   --  BEHAVIOR SECTION
   --------------------
   inst10: or2 PORT MAP (a=>read_ipd, b=>A, z=>C_inv);
   inst11: inv PORT MAP (a=>C_inv, z=>C);
   inst12: or2 PORT MAP (a=>C, b=>D, z=>A_inv);
   inst13: inv PORT MAP (a=>A_inv, z=>A);
   inst14: or2 PORT MAP (a=>D, b=>E, z=>B_inv);
   inst15: inv PORT MAP (a=>B_inv, z=>B);
   inst16: or2 PORT MAP (a=>C, b=>PRMBDET_int, z=>E_inv);
   inst17: inv PORT MAP (a=>E_inv, z=>E);
   inst18: or3 PORT MAP (a=>B, b=>read_ipd, c=>PRMBDET_int, z=>D_inv);
   inst19: inv PORT MAP (a=>D_inv, z=>D);

   P1 : PROCESS (dqsi_ipd)
   BEGIN
      IF (dqsi_ipd = 'X') THEN
         PRMBDET_int <= '1';
      ELSE
         PRMBDET_int <= dqsi_ipd;
      END IF;
   END PROCESS;

   P2 : PROCESS (D)
   BEGIN
      IF (D'event and D = '0') THEN
         DDRCLKPOL_int <= clk_ipd;
      END IF;
   END PROCESS;

   P3 : PROCESS (clk_ipd, DDRCLKPOL_int)
   BEGIN
      IF (DDRCLKPOL_int = '0') THEN
         CLKP <= clk_ipd;
      ELSIF (DDRCLKPOL_int = '1') THEN
         CLKP <= not clk_ipd;
      END IF;
   END PROCESS;

   P4 : PROCESS (clk_ipd)
   BEGIN
      IF (clk_ipd'event and clk_ipd = '1') THEN
         clk_rising_edge_count <= clk_rising_edge_count + 1;
         clk_last_rising_edge <= NOW;
      END IF;
   END PROCESS;

   P5 : PROCESS (clk_ipd)
   BEGIN
      IF (clk_ipd'event and clk_ipd = '0') THEN
         IF (clk_rising_edge_count >= 1) THEN
            quarter_period <= (NOW - clk_last_rising_edge) / 2;
         END IF;
      END IF;
   END PROCESS;

   P6 : PROCESS (dqsi_ipd, dqsdel_ipd)
   BEGIN
      IF (dqsdel_ipd = '1') THEN
         IF (quarter_period > 0 ps) THEN
            DQSO_int <= transport dqsi_ipd after (quarter_period - 0.8 ns);
            DQSC_int <= dqsi_ipd;
         END IF;
      ELSE
         DQSO_int <= '0';
         DQSC_int <= '0';
      END IF;
   END PROCESS;

   P7 : PROCESS (DQSO_int, CLKP)
   BEGIN
      IF (CLKP = '1') THEN
         DQSO_int1 <= '0';
      ELSIF (DQSO_int'event and DQSO_int'last_value = '0') THEN
         DQSO_int1 <= '1';
      END IF;
   END PROCESS;

   DQSO_int0 <= DQSO_int;

   DQSO_int2 <= transport (DQSO_int1 or DQSO_int0) after 0.8 ns;
   ddrclkpol <= DDRCLKPOL_int; 
   prmbdet <= PRMBDET_int;
   dqso <= DQSO_int2;
   dqsc <= DQSC_int;

END v;

CONFIGURATION dqsbufbc OF dqsbufb IS
  FOR v
    FOR ALL: or2 USE ENTITY work.or2(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
  END FOR;
END dqsbufbc;

--
---
library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


-- ************************************************************************
-- Entity definition
-- ************************************************************************

entity CCU2 is

   generic (
      inject1_0 : string := "YES";
      inject1_1 : string := "YES";
      init0: string := "0x0000";
      init1: string := "0x0000"

   );

   port (
      A0,A1 : in std_ulogic;
      B0,B1 : in std_ulogic;
      C0,C1 : in std_ulogic;
      D0,D1 : in std_ulogic;
      CIN : in std_ulogic;
      S0,S1 : out std_ulogic;
      COUT0,COUT1 : out std_ulogic
   );

end CCU2;

architecture bev of CCU2 is
   ------------------------------------------------------------------
   function hex2bin (hex: Character) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR (3 downto 0);
   begin
        case hex is
          when '0' =>
             result := "0000";
          when '1' =>
             result := "0001";
          when '2' =>
             result := "0010";
          when '3' =>
             result := "0011";
          when '4' =>
             result := "0100";
          when '5' =>
             result := "0101";
          when '6' =>
             result := "0110";
          when '7' =>
             result := "0111";
          when '8' =>
             result := "1000";
          when '9' =>
             result := "1001";
          when 'A'|'a' =>
             result := "1010";
          when 'B'|'b' =>
             result := "1011";
          when 'C'|'c' =>
             result := "1100";
          when 'D'|'d' =>
             result := "1101";
          when 'E'|'e' =>
             result := "1110";
          when 'F'|'f' =>
             result := "1111";
          when others =>
             null;
        end case;
        return result;
   end;
 
   function hex2bin (hex: String) return STD_LOGIC_VECTOR is
        -- skip 0x of hex string
        constant length : Integer := hex'length - 2;
        variable result : STD_LOGIC_VECTOR (4*length-1 downto 0);
   begin
        for i in 0 to length-1 loop
           result ((length-i)*4-1 downto (length-i-1)*4) := hex2bin(hex(i+3));
        end loop;
        return result;
   end;

   -----------------------------------------------------

   signal init_vec0 : std_logic_vector( 15 downto 0);
   signal init_vec1 : std_logic_vector( 15 downto 0);

   signal lut2_init0 : std_logic_vector (3 downto 0); 
   signal lut2_init1 : std_logic_vector (3 downto 0);

   signal lut2_sel0, lut2_sel1, lut4_sel0, lut4_sel1 : integer :=0;
   signal lut2_out0, lut2_out1 : std_ulogic;
   signal prop0, prop1, gen0, gen1, cout_sig0, cout_sig1 : std_ulogic;
 
   -----------------------------------------------------

begin


   init_vec0 <= hex2bin(init0);
   init_vec1 <= hex2bin(init1);

   lut2_init0 <= init_vec0( 15 downto 12 );
   lut2_init1 <= init_vec1( 15 downto 12 );

   lut2_sel0 <= conv_integer (B0 & A0);
   lut2_sel1 <= conv_integer (B1 & A1);
   lut4_sel0 <= conv_integer (D0 & C0 & B0 & A0);
   lut4_sel1 <= conv_integer (D1 & C1 & B1 & A1);

   prop0 <= init_vec0(lut4_sel0) ; 
   prop1 <= init_vec1(lut4_sel1); 

   lut2_out0 <= lut2_init0(lut2_sel0); 
   lut2_out1 <= lut2_init1(lut2_sel1); 

   gen0 <= '1' when (inject1_0 = "YES") else
           '1' when (inject1_0 = "yes") else
           not(lut2_out0) ;
   gen1 <= '1' when (inject1_1 = "YES") else 
           '1' when (inject1_0 = "yes") else
           not(lut2_out1) ;

   cout_sig0 <= (not(prop0) and gen0 ) or (prop0 and CIN);
   cout_sig1 <= (not(prop1) and gen1 ) or (prop1 and cout_sig0);

   COUT0 <= cout_sig0;
   COUT1 <= cout_sig1; 

   S0 <=  prop0 xor CIN;  
   S1 <=  prop1 xor cout_sig0;

end bev;

-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_CNT.vhd,v 1.1 2005/12/06 13:00:23 tame Exp $ 
--
 
--
----- buf -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
 
-- entity declaration --
ENTITY buf IS
    GENERIC (
        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
	MsgOn           : boolean := FALSE;
        InstancePath    : string  := "buf";
        tpd_a_z		: VitalDelayType01 := (0.001 ns, 0.001 ns);
        tipd_a		: VitalDelayType01 := (0.0 ns, 0.0 ns)) ;
 
    PORT (
        a  : IN std_logic;
        z  : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF buf : ENTITY IS TRUE;
 
END buf ;
 
-- architecture body --
ARCHITECTURE v OF buf IS
    ATTRIBUTE Vital_Level1 OF v : ARCHITECTURE IS TRUE;
 
    SIGNAL a_ipd  : std_logic := 'X';
 
BEGIN
 
   ---------------------
   --  input path delays
   ---------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(a_ipd, a, tipd_a);
   END BLOCK;
 
   --------------------
   --  behavior section
   --------------------
   VitalBehavior : process (a_ipd)
 
   -- functionality results
   VARIABLE results : std_logic_vector(1 to 1) := (others => 'X');
   ALIAS z_zd       : std_ulogic IS results(1);
 
   -- output glitch detection VARIABLEs
   VARIABLE z_GlitchData     : VitalGlitchDatatype;
 
   BEGIN
 
   IF (TimingChecksOn) THEN
    -----------------------------------
    -- no timing checks for a comb gate
    -----------------------------------
   END IF;
 
   -----------------------------------
   -- functionality section.
   -----------------------------------
   z_zd := VitalBuf(a_ipd);
 
   -----------------------------------
   -- path delay section.
   -----------------------------------
   VitalPathDelay01 (
     OutSignal => z,
     OutSignalName => "z",
     OutTemp => z_zd,
     Paths => (0 => (InputChangeTime => a_ipd'last_event, 
		     PathDelay => tpd_a_z, 
		     PathCondition => TRUE)),
     GlitchData => z_GlitchData,
     Mode => OnDetect, XOn => XOn, MsgOn => MsgOn);
 
   END process;
 
END v;



--
----- cd2 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY cd2 IS
  GENERIC (
    InstancePath  : string := "cd2");
  PORT (
    ci, pc0, pc1 : IN std_logic;
    co, nc0, nc1 : OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF cd2 : ENTITY IS TRUE;
 
END cd2;

ARCHITECTURE v OF cd2 IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL cii, i4, i6, i16, i18, i29, i31, i42: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>pc0, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>pc0, z=>i6);
  inst13: xnor2 PORT MAP (a=>pc0, b=>cii, z=>nc0);
  inst24: and2 PORT MAP (a=>pc1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>pc1, z=>co);
  inst26: xnor2 PORT MAP (a=>pc1, b=>i6, z=>nc1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
END v;

CONFIGURATION cd2c OF cd2 IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END cd2c;



--
----- cu2 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY cu2 IS
  GENERIC (
    InstancePath  : string := "cu2");
  PORT (
    ci, pc0, pc1: IN std_logic;
    co, nc0, nc1: OUT std_logic);
 
    ATTRIBUTE Vital_Level0 OF cu2 : ENTITY IS TRUE;
 
END cu2;

ARCHITECTURE v OF cu2 IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL cii, i6, i18, i31: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>pc0, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>pc0, b=>cii, z=>nc0);
  inst24: and2 PORT MAP (a=>pc1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>pc1, b=>i6, z=>nc1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
END v;

CONFIGURATION cu2c OF cu2 IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END cu2c;


--
----- cb2 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
----LIBRARY work;
USE work.components.all;

ENTITY cb2 IS
  GENERIC (
    InstancePath  : string := "cb2");
  PORT (
    ci, pc0, pc1, con: IN std_logic;
    co, nc0, nc1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF cb2 : ENTITY IS TRUE;

END cb2;

ARCHITECTURE v OF cb2 IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL cii, conn, i3, i4, i5, i6, i17, i15, i16, coni: std_logic;
 
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>pc0, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>pc0, b=>conn, c=>cii, z=>nc0);
  inst2: and2 PORT MAP (a=>conn, b=>pc0, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>pc1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>pc1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>pc1, b=>conn, c=>i6, z=>nc1);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
END v;

CONFIGURATION cb2c OF cb2 IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END cb2c;


--
----- lb2p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lb2p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3ax");
  PORT (
    d0, d1, ci, sp, ck, sd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3ax : ENTITY IS TRUE;

END lb2p3ax;

ARCHITECTURE v OF lb2p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=> q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=> q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION lb2p3axc OF lb2p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3axc;


--
----- lb2p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lb2p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3ay");
  PORT (
    d0, d1, ci, sp, ck, sd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3ay : ENTITY IS TRUE;

END lb2p3ay;

ARCHITECTURE v OF lb2p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=> q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=> q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION lb2p3ayc OF lb2p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3ayc;


--
----- lb2p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb2p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3bx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3bx : ENTITY IS TRUE;

END lb2p3bx;

ARCHITECTURE v OF lb2p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lb2p3bxc OF lb2p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3bxc;


--
----- lb2p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb2p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3dx");
  PORT (
    d0, d1, ci, sp, ck, sd, cd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3dx : ENTITY IS TRUE;

END lb2p3dx;

ARCHITECTURE v OF lb2p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lb2p3dxc OF lb2p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3dxc;


--
----- lb2p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb2p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3ix");
  PORT (
    d0, d1, ci, sp, ck, sd, cd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3ix : ENTITY IS TRUE;

END lb2p3ix;

ARCHITECTURE v OF lb2p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lb2p3ixc OF lb2p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3ixc;


--
----- lb2p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb2p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb2p3jx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd, con: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb2p3jx : ENTITY IS TRUE;

END lb2p3jx;

ARCHITECTURE v OF lb2p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i19, coni: std_logic;

BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>co);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);

  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lb2p3jxc OF lb2p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb2p3jxc;



--
----- lb4p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lb4p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3ax");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3ax : ENTITY IS TRUE;

END lb4p3ax;

ARCHITECTURE v OF lb4p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=> q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=> q1_1);
  inst70: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=> q2_1);
  inst71: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=> q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION lb4p3axc OF lb4p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3axc;


--
----- lb4p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lb4p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3ay");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3ay : ENTITY IS TRUE;

END lb4p3ay;

ARCHITECTURE v OF lb4p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=> q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=> q1_1);
  inst70: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=> q2_1);
  inst71: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=> q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION lb4p3ayc OF lb4p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3ayc;


--
----- lb4p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb4p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3bx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3bx : ENTITY IS TRUE;

END lb4p3bx;

ARCHITECTURE v OF lb4p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lb4p3bxc OF lb4p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3bxc;


--
----- lb4p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb4p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3dx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3dx : ENTITY IS TRUE;

END lb4p3dx;

ARCHITECTURE v OF lb4p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lb4p3dxc OF lb4p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3dxc;


--
----- lb4p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb4p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3ix");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3ix : ENTITY IS TRUE;

END lb4p3ix;

ARCHITECTURE v OF lb4p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lb4p3ixc OF lb4p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3ixc;


--
----- lb4p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lb4p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lb4p3jx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd, con: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lb4p3jx : ENTITY IS TRUE;

END lb4p3jx;

ARCHITECTURE v OF lb4p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT inv
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xor3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, conn, i3, i4, i5, i6, i7, i17,
    i15, i16, i18, i19, i30, i28, i29, i31, i32, i43, i41, i42, i45,
    coni: std_logic;
BEGIN
  inst10: and2 PORT MAP (a=>cii, b=>conn, z=>i3);
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>i3, b=>i4, c=>i5, z=>i6);
  inst13: xor3 PORT MAP (a=>q0_1, b=>conn, c=>cii, z=>i7);
  inst2: and2 PORT MAP (a=>conn, b=>q0_1, z=>i5);
  inst22: and2 PORT MAP (a=>conn, b=>q1_1, z=>i17);
  inst23: and2 PORT MAP (a=>i6, b=>conn, z=>i15);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i15, b=>i16, c=>i17, z=>i18);
  inst26: xor3 PORT MAP (a=>q1_1, b=>conn, c=>i6, z=>i19);
  inst35: and2 PORT MAP (a=>conn, b=>q2_1, z=>i30);
  inst36: and2 PORT MAP (a=>i18, b=>conn, z=>i28);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i28, b=>i29, c=>i30, z=>i31);
  inst39: xor3 PORT MAP (a=>q2_1, b=>conn, c=>i18, z=>i32);
  inst48: and2 PORT MAP (a=>conn, b=>q3_1, z=>i43);
  inst49: and2 PORT MAP (a=>i31, b=>conn, z=>i41);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i41, b=>i42, c=>i43, z=>co);
  inst52: xor3 PORT MAP (a=>q3_1, b=>conn, c=>i31, z=>i45);
  inst96: inv PORT MAP (a=>coni, z=>conn);
  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  inst991: buf PORT MAP (a=>con, z=>coni);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lb4p3jxc OF lb4p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: inv USE ENTITY work.inv(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xor3 USE ENTITY work.xor3(v); END FOR;
  END FOR;
END lb4p3jxc;




--
----- ld2p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY ld2p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3ax");
  PORT (
    d0, d1, ci, sp, ck, sd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3ax : ENTITY IS TRUE;

END ld2p3ax;

ARCHITECTURE v OF ld2p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION ld2p3axc OF ld2p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3axc;


--
----- ld2p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY ld2p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3ay");
  PORT (
    d0, d1, ci, sp, ck, sd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3ay : ENTITY IS TRUE;

END ld2p3ay;

ARCHITECTURE v OF ld2p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION ld2p3ayc OF ld2p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3ayc;


--
----- ld2p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld2p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3bx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3bx : ENTITY IS TRUE;

END ld2p3bx;

ARCHITECTURE v OF ld2p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION ld2p3bxc OF ld2p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3bxc;


--
----- ld2p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld2p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3dx");
  PORT (
    d0, d1, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3dx : ENTITY IS TRUE;

END ld2p3dx;

ARCHITECTURE v OF ld2p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION ld2p3dxc OF ld2p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3dxc;


--
----- ld2p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld2p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3ix");
  PORT (
    d0, d1, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3ix : ENTITY IS TRUE;

END ld2p3ix;

ARCHITECTURE v OF ld2p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION ld2p3ixc OF ld2p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3ixc;


--
----- ld2p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld2p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld2p3jx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld2p3jx : ENTITY IS TRUE;

END ld2p3jx;

ARCHITECTURE v OF ld2p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i4, i6, i7, i16, i19 : std_logic;

BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>co);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION ld2p3jxc OF ld2p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld2p3jxc;


--
----- ld4p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY ld4p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3ax");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3ax : ENTITY IS TRUE;

END ld4p3ax;

ARCHITECTURE v OF ld4p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst70: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=>
    q2_1);
  inst71: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=>
    q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION ld4p3axc OF ld4p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3axc;


--
----- ld4p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY ld4p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3ay");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3ay : ENTITY IS TRUE;

END ld4p3ay;

ARCHITECTURE v OF ld4p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst70: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=>
    q2_1);
  inst71: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=>
    q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION ld4p3ayc OF ld4p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3ayc;


--
----- ld4p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld4p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3bx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3bx : ENTITY IS TRUE;

END ld4p3bx;

ARCHITECTURE v OF ld4p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION ld4p3bxc OF ld4p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3bxc;


--
----- ld4p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld4p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3dx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3dx : ENTITY IS TRUE;

END ld4p3dx;

ARCHITECTURE v OF ld4p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION ld4p3dxc OF ld4p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3dxc;


--
----- ld4p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld4p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3ix");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3ix : ENTITY IS TRUE;

END ld4p3ix;

ARCHITECTURE v OF ld4p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION ld4p3ixc OF ld4p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3ixc;


--
----- ld4p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY ld4p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "ld4p3jx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF ld4p3jx : ENTITY IS TRUE;

END ld4p3jx;

ARCHITECTURE v OF ld4p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT or3
    PORT (
      a, b, c: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT xnor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i4, i6, i7, i16, i18, i19, i29,
    i31, i32, i42, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i4);
  inst12: or3 PORT MAP (a=>cii, b=>i4, c=>q0_1, z=>i6);
  inst13: xnor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i16);
  inst25: or3 PORT MAP (a=>i6, b=>i16, c=>q1_1, z=>i18);
  inst26: xnor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i29);
  inst38: or3 PORT MAP (a=>i18, b=>i29, c=>q2_1, z=>i31);
  inst39: xnor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>i42);
  inst51: or3 PORT MAP (a=>i31, b=>i42, c=>q3_1, z=>co);
  inst52: xnor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION ld4p3jxc OF ld4p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: or3 USE ENTITY work.or3(v); END FOR;
    FOR ALL: xnor2 USE ENTITY work.xnor2(v); END FOR;
  END FOR;
END ld4p3jxc;




--
----- lu2p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lu2p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3ax");
  PORT (
    d0, d1, ci, sp, ck, sd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3ax : ENTITY IS TRUE;

END lu2p3ax;

ARCHITECTURE v OF lu2p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19 : std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION lu2p3axc OF lu2p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3axc;


--
----- lu2p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lu2p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3ay");
  PORT (
    d0, d1, ci, sp, ck, sd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3ay : ENTITY IS TRUE;

END lu2p3ay;

ARCHITECTURE v OF lu2p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;

CONFIGURATION lu2p3ayc OF lu2p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3ayc;


--
----- lu2p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu2p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3bx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3bx : ENTITY IS TRUE;

END lu2p3bx;

ARCHITECTURE v OF lu2p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);

  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lu2p3bxc OF lu2p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3bxc;


--
----- lu2p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu2p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3dx");
  PORT (
    d0, d1, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3dx : ENTITY IS TRUE;

END lu2p3dx;

ARCHITECTURE v OF lu2p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lu2p3dxc OF lu2p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3dxc;


--
----- lu2p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu2p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3ix");
  PORT (
    d0, d1, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3ix : ENTITY IS TRUE;

END lu2p3ix;

ARCHITECTURE v OF lu2p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lu2p3ixc OF lu2p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3ixc;


--
----- lu2p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu2p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu2p3jx");
  PORT (
    d0, d1, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu2p3jx : ENTITY IS TRUE;

END lu2p3jx;

ARCHITECTURE v OF lu2p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, cii, i6, i7, i19: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>co);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
END v;


CONFIGURATION lu2p3jxc OF lu2p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu2p3jxc;


--
----- lu4p3ax -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lu4p3ax IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3ax");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3ax : ENTITY IS TRUE;

END lu4p3ax;

ARCHITECTURE v OF lu4p3ax IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3az
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst70: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=>
    q2_1);
  inst71: fl1p3az generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=>
    q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION lu4p3axc OF lu4p3ax IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3az USE ENTITY work.fl1p3az(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3axc;


--
----- lu4p3ay -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;

ENTITY lu4p3ay IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3ay");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3ay : ENTITY IS TRUE;

END lu4p3ay;

ARCHITECTURE v OF lu4p3ay IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3ay
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, q=>
    q0_1);
  inst69: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, q=>
    q1_1);
  inst70: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, q=>
    q2_1);
  inst71: fl1p3ay generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, q=>
    q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;

CONFIGURATION lu4p3ayc OF lu4p3ay IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3ay USE ENTITY work.fl1p3ay(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3ayc;


--
----- lu4p3bx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu4p3bx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3bx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3bx : ENTITY IS TRUE;

END lu4p3bx;

ARCHITECTURE v OF lu4p3bx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3bx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3bx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lu4p3bxc OF lu4p3bx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3bx USE ENTITY work.fl1p3bx(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3bxc;


--
----- lu4p3dx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu4p3dx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3dx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3dx : ENTITY IS TRUE;

END lu4p3dx;

ARCHITECTURE v OF lu4p3dx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3dx
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3dx generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lu4p3dxc OF lu4p3dx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3dx USE ENTITY work.fl1p3dx(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3dxc;


--
----- lu4p3ix -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu4p3ix IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3ix");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, cd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3ix : ENTITY IS TRUE;

END lu4p3ix;

ARCHITECTURE v OF lu4p3ix IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3iy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, cd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q0_1);
  inst69: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q1_1);
  inst70: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q2_1);
  inst71: fl1p3iy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, cd=>
    cd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lu4p3ixc OF lu4p3ix IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3iy USE ENTITY work.fl1p3iy(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3ixc;


--
----- lu4p3jx -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
--LIBRARY work;
USE work.components.all;
ENTITY lu4p3jx IS
  GENERIC (

    gsr  : String := "ENABLED";

    InstancePath  : string := "lu4p3jx");
  PORT (
    d0, d1, d2, d3, ci, sp, ck, sd, pd: IN std_logic;
    co, q0, q1, q2, q3: OUT std_logic);

    ATTRIBUTE Vital_Level0 OF lu4p3jx : ENTITY IS TRUE;

END lu4p3jx;

ARCHITECTURE v OF lu4p3jx IS
  ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
  COMPONENT and2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT buf
    PORT (
      a: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  COMPONENT fl1p3jy
    generic (gsr  : String := "ENABLED");
    PORT (
      d0, d1, sp, ck, sd, pd: IN std_logic;
      q: OUT std_logic);
  END COMPONENT;
  COMPONENT xor2
    PORT (
      a, b: IN std_logic;
      z: OUT std_logic);
  END COMPONENT;
  SIGNAL q0_1, q1_1, q2_1, q3_1, cii, i6, i7, i18, i19, i31, i32, i45: std_logic;
BEGIN
  inst11: and2 PORT MAP (a=>q0_1, b=>cii, z=>i6);
  inst13: xor2 PORT MAP (a=>q0_1, b=>cii, z=>i7);
  inst24: and2 PORT MAP (a=>q1_1, b=>i6, z=>i18);
  inst26: xor2 PORT MAP (a=>q1_1, b=>i6, z=>i19);
  inst37: and2 PORT MAP (a=>q2_1, b=>i18, z=>i31);
  inst39: xor2 PORT MAP (a=>q2_1, b=>i18, z=>i32);
  inst50: and2 PORT MAP (a=>q3_1, b=>i31, z=>co);
  inst52: xor2 PORT MAP (a=>q3_1, b=>i31, z=>i45);
  inst68: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i7, d1=>d0, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q0_1);
  inst69: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i19, d1=>d1, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q1_1);
  inst70: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i32, d1=>d2, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q2_1);
  inst71: fl1p3jy generic map (gsr => gsr)
          PORT MAP (d0=>i45, d1=>d3, sp=>sp, ck=>ck, sd=>sd, pd=>
    pd, q=>q3_1);
  inst990: buf PORT MAP (a=>ci, z=>cii);
  q0 <= q0_1;
  q1 <= q1_1;
  q2 <= q2_1;
  q3 <= q3_1;
END v;


CONFIGURATION lu4p3jxc OF lu4p3jx IS
  FOR v
    FOR ALL: and2 USE ENTITY work.and2(v); END FOR;
    FOR ALL: buf USE ENTITY work.buf(v); END FOR;
    FOR ALL: fl1p3jy USE ENTITY work.fl1p3jy(v); END FOR;
    FOR ALL: xor2 USE ENTITY work.xor2(v); END FOR;
  END FOR;
END lu4p3jxc;

-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_MEM.vhd,v 1.1 2005/12/06 13:00:24 tame Exp $ 
--


 
--
----- package mem1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE mem1 IS
   TYPE mem_type_1 IS array (natural range <>) OF std_logic;
   TYPE mem_type_2 IS array (natural range <>) OF std_logic_vector(1 downto 0);
   TYPE mem_type_4 IS array (natural range <>) OF std_logic_vector(3 downto 0);
   function hex2bin_2 (hex: Character) return STD_LOGIC_VECTOR;
   FUNCTION hex2bin_4 (hex: character) RETURN std_logic_vector;
   FUNCTION init_ram (hex: string) RETURN mem_type_4;
   FUNCTION init_ram (hex: string) RETURN mem_type_2;
   FUNCTION init_ram_1 (hex: string) RETURN mem_type_1;
END mem1;
 
PACKAGE BODY mem1 IS

   FUNCTION init_ram (hex: string) RETURN mem_type_2 IS
        -- skip 0x OF hex string
        CONSTANT length : integer := hex'length - 2;
        VARIABLE result : mem_type_2 (length-1 downto 0);
   BEGIN
        FOR i in 0 to length-1 LOOP
           result (length-1-i) := hex2bin_2 (hex(i+3));
        END LOOP;
        RETURN result;
   END;

   function hex2bin_2 (hex: Character) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR (1 downto 0);
   begin
        case hex is
          when '0' =>
             result := "00";
          when '1' =>
             result := "01";
          when '2' =>
             result := "10";
          when '3' =>
             result := "11";
          when '4' =>
             result := "00";
          when '5' =>
             result := "01";
          when '6' =>
             result := "10";
          when '7' =>
             result := "11";
          when '8' =>
             result := "00";
          when '9' =>
             result := "01";
          when 'A'|'a' =>
             result := "10";
          when 'B'|'b' =>
             result := "11";
          when 'C'|'c' =>
             result := "00";
          when 'D'|'d' =>
             result := "01";
          when 'E'|'e' =>
             result := "10";
          when 'F'|'f' =>
             result := "11";
          when others =>
             null;
        end case;
        return result;
   end;

   FUNCTION hex2bin_4 (hex: character) RETURN std_logic_vector IS
        VARIABLE result : std_logic_vector (3 downto 0);
   BEGIN
        CASE hex IS
          WHEN '0' => 
             result := "0000";
          WHEN '1' => 
             result := "0001";
          WHEN '2' => 
             result := "0010";
          WHEN '3' => 
             result := "0011";
          WHEN '4' => 
             result := "0100";
          WHEN '5' => 
             result := "0101";
          WHEN '6' => 
             result := "0110";
          WHEN '7' => 
             result := "0111";
          WHEN '8' => 
             result := "1000";
          WHEN '9' => 
             result := "1001";
          WHEN 'A'|'a' => 
             result := "1010";
          WHEN 'B'|'b' => 
             result := "1011";
          WHEN 'C'|'c' => 
             result := "1100";
          WHEN 'D'|'d' => 
             result := "1101";
          WHEN 'E'|'e' => 
             result := "1110";
          WHEN 'F'|'f' => 
             result := "1111";
          WHEN others =>
             NULL;
        END CASE;
        RETURN result;
   END; 
 
   FUNCTION init_ram (hex: string) RETURN mem_type_4 IS
	-- skip 0x OF hex string
        CONSTANT length : integer := hex'length - 2;
        VARIABLE result : mem_type_4 (length-1 downto 0);
   BEGIN
        FOR i in 0 to length-1 LOOP
           result (length-1-i) := hex2bin_4 (hex(i+3));
        END LOOP;
        RETURN result;
   END;

   FUNCTION init_ram_1 (hex: string) RETURN mem_type_1 IS
        -- skip 0x OF hex string
        CONSTANT length : integer := hex'length - 2;
        VARIABLE result : mem_type_1 ((4*length)-1 downto 0);
        VARIABLE result1 : std_logic_vector((4*length)-1 downto 0);
   BEGIN
        FOR i in 0 to length-1 LOOP
           result1 ((4*(length-i))-1 downto (4*(length-1-i))) := hex2bin_4 (hex(i+3));

           FOR j in 0 to 3 LOOP
             result(((4*length)-1)-j-(4*i)) := result1(((4*length)-1)-j-(4*i)); 
           END LOOP;

        END LOOP;
        RETURN result;
   END;

END mem1;



--
----- PACKAGE mem2 -----
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
package mem2 is
   function hex2bin (hex: String) return STD_LOGIC_VECTOR;
   function hex2bin (hex: Character) return STD_LOGIC_VECTOR;
end mem2;
 
package body mem2 is
 
   function hex2bin (hex: Character) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR (3 downto 0);
   begin
        case hex is
          when '0' =>
             result := "0000";
          when '1' =>
             result := "0001";
          when '2' =>
             result := "0010";
          when '3' =>
             result := "0011";
          when '4' =>
             result := "0100";
          when '5' =>
             result := "0101";
          when '6' =>
             result := "0110";
          when '7' =>
             result := "0111";
          when '8' =>
             result := "1000";
          when '9' =>
             result := "1001";
          when 'A'|'a' =>
             result := "1010";
          when 'B'|'b' =>
             result := "1011";
          when 'C'|'c' =>
             result := "1100";
          when 'D'|'d' =>
             result := "1101";
          when 'E'|'e' =>
             result := "1110";
          when 'F'|'f' =>
             result := "1111";
          when others =>
             null;
        end case;
        return result;
   end;
 
   function hex2bin (hex: String) return STD_LOGIC_VECTOR is
        -- skip 0x of hex string
        constant length : Integer := hex'length - 2;
        variable result : STD_LOGIC_VECTOR (4*length-1 downto 0);
   begin
        for i in 0 to length-1 loop
           result ((length-i)*4-1 downto (length-i-1)*4) := hex2bin(hex(i+3));
        end loop;
        return result;
   end;
 
end mem2;

--
----- package mem3 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

PACKAGE mem3 IS
   TYPE mem_type_5 IS array (Integer range <>) OF std_logic_vector(17 downto 0);
   TYPE mem_type_6 IS array (Integer range <>) OF std_logic_vector(15 downto 0);
   FUNCTION hex2bin (hex: character) RETURN std_logic_vector;
   FUNCTION str3_slv12 (hex: string) RETURN std_logic_vector;
   FUNCTION data2data (data_w: integer) RETURN integer;
   FUNCTION data2addr_w (data_w: integer) RETURN integer;
   FUNCTION data2data_w (data_w: integer) RETURN integer;
   FUNCTION init_ram (hex: string; DATA_WIDTH_A : integer; DATA_WIDTH_B : integer) RETURN std_logic_vector;
   FUNCTION init_ram1 (hex: string) RETURN mem_type_6;
   FUNCTION str2slv (str: in string) RETURN std_logic_vector;
   FUNCTION Valid_Address (IN_ADDR : in std_logic_vector) return boolean;
END mem3;
PACKAGE BODY mem3 IS

   FUNCTION hex2bin (hex: character) RETURN std_logic_vector IS
        VARIABLE result : std_logic_vector (3 downto 0);
   BEGIN
        CASE hex IS
          WHEN '0' =>
             result := "0000";
          WHEN '1' =>
             result := "0001";
          WHEN '2' =>
             result := "0010";
          WHEN '3' =>
             result := "0011";
          WHEN '4' =>
             result := "0100";
          WHEN '5' =>
             result := "0101";
          WHEN '6' =>
             result := "0110";
          WHEN '7' =>
             result := "0111";
          WHEN '8' =>
             result := "1000";
          WHEN '9' =>
             result := "1001";
          WHEN 'A'|'a' =>
             result := "1010";
          WHEN 'B'|'b' =>
             result := "1011";
          WHEN 'C'|'c' =>
             result := "1100";
          WHEN 'D'|'d' =>
             result := "1101";
          WHEN 'E'|'e' =>
             result := "1110";
          WHEN 'F'|'f' =>
             result := "1111";
          WHEN 'X'|'x' =>
             result := "XXXX";
          WHEN others =>
             NULL;
        END CASE;
        RETURN result;
   END;

   FUNCTION str5_slv18 (s : string(5 downto 1)) return std_logic_vector is
        VARIABLE result : std_logic_vector(17 downto 0);
   BEGIN
       FOR i in 0 to 3 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(s(i+1));
       END LOOP;
          result(17 downto 16) := hex2bin(s(5))(1 downto 0);
       RETURN result;
   END;

   FUNCTION str4_slv16 (s : string(4 downto 1)) return std_logic_vector is
        VARIABLE result : std_logic_vector(15 downto 0);
   BEGIN
       FOR i in 0 to 3 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(s(i+1));
       END LOOP;
       RETURN result;
   END;

   FUNCTION str3_slv12 (hex: string) return std_logic_vector is
        VARIABLE result : std_logic_vector(11 downto 0);
   BEGIN
       FOR i in 0 to 2 LOOP
          result(((i+1)*4)-1 downto (i*4)) := hex2bin(hex(i+1));
       END LOOP;
       RETURN result;
   END;

   FUNCTION data2addr_w (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 13;
          WHEN 2 =>
             result := 12;
          WHEN 4 =>
             result := 11;
          WHEN 9 =>
             result := 10;
          WHEN 18 =>
             result := 9;
          WHEN 36 =>
             result := 8;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION data2data_w (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 1;
          WHEN 2 =>
             result := 2;
          WHEN 4 =>
             result := 4;
          WHEN 9 =>
             result := 9;
          WHEN 18 =>
             result := 18;
          WHEN 36 =>
             result := 18;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION data2data (data_w : integer) return integer is
        VARIABLE result : integer;
   BEGIN
        CASE data_w IS
          WHEN 1 =>
             result := 8;
          WHEN 2 =>
             result := 4;
          WHEN 4 =>
             result := 2;
          WHEN 9 =>
             result := 36864;
          WHEN 18 =>
             result := 36864;
          WHEN 36 =>
             result := 36864;
          WHEN others =>
             NULL;
        END CASE;
       RETURN result;
   END;

   FUNCTION init_ram (hex: string; DATA_WIDTH_A : integer; DATA_WIDTH_B : integer) RETURN std_logic_vector IS
        CONSTANT length : integer := hex'length;
        VARIABLE result1 : mem_type_5 (0 to ((length/5)-1));
        VARIABLE result : std_logic_vector(((length*18)/5)-1 downto 0);
   BEGIN
       FOR i in 0 to ((length/5)-1) LOOP
         result1(i) := str5_slv18(hex((i+1)*5 downto (i*5)+1));
       END LOOP;
       IF (DATA_WIDTH_A >= 9 and DATA_WIDTH_B >= 9) THEN
          FOR j in 0 to 511 LOOP
            result(((j*18) + 17) downto (j*18)) := result1(j)(17 downto 0);
          END LOOP;
       ELSE
          FOR j in 0 to 511 LOOP
            result(((j*18) + 7) downto (j*18)) := result1(j)(7 downto 0);
            result((j*18) + 8) := '0';
            result(((j*18) + 16) downto ((j*18) + 9)) := result1(j)(15 downto 8);
            result((j*18) + 17) := '0';
          END LOOP;
       END IF;
       RETURN result;
   END;

   FUNCTION init_ram1 (hex: string) RETURN mem_type_6 IS
        CONSTANT length : integer := hex'length;
        VARIABLE result : mem_type_6 (0 to ((length/4)-1));
   BEGIN
       FOR i in 0 to ((length/4)-1) LOOP
         result(i) := str4_slv16(hex((i+1)*4 downto (i*4)+1));
       END LOOP;
       RETURN result;
   END;

-- String to std_logic_vector

  FUNCTION str2slv (
      str : in string
  ) return std_logic_vector is

  variable j : integer := str'length;
  variable slv : std_logic_vector (str'length downto 1);

  begin
      for i in str'low to str'high loop
          case str(i) is
              when '0' => slv(j) := '0';
              when '1' => slv(j) := '1';
              when 'X' => slv(j) := 'X';
              when 'U' => slv(j) := 'U';
              when others => slv(j) := 'X';
          end case;
          j := j - 1;
      end loop;
      return slv;
  end str2slv;

function Valid_Address (
    IN_ADDR : in std_logic_vector
 ) return boolean is

    variable v_Valid_Flag : boolean := TRUE;

begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Address;

END mem3 ;

--
----- cell rom256x1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem2.all;
 
-- entity declaration --
ENTITY rom256x1 IS
  GENERIC (
        initval : string := "0x0000000000000000000000000000000000000000000000000000000000000000";
 
        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string  := "rom256x1";
 
        -- input SIGNAL delays
        tipd_ad0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad4  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad5  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad6  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad7  : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
 
 
        -- propagation delays
        tpd_ad0_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad1_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad2_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad3_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad4_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad5_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad6_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad7_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns));
 
  port (ad0  : IN   std_logic;
        ad1  : IN   std_logic;
        ad2  : IN   std_logic;
        ad3  : IN   std_logic;
        ad4  : IN   std_logic;
        ad5  : IN   std_logic;
        ad6  : IN   std_logic;
        ad7  : IN   std_logic;
        do0   : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF rom256x1 : ENTITY IS TRUE;
 
END rom256x1;
 
-- architecture body --
ARCHITECTURE v OF rom256x1 IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL ad0_ipd  : std_logic := 'X';
   SIGNAL ad1_ipd  : std_logic := 'X';
   SIGNAL ad2_ipd  : std_logic := 'X';
   SIGNAL ad3_ipd  : std_logic := 'X';
   SIGNAL ad4_ipd  : std_logic := 'X';
   SIGNAL ad5_ipd  : std_logic := 'X';
   SIGNAL ad6_ipd  : std_logic := 'X';
   SIGNAL ad7_ipd  : std_logic := 'X';
 
BEGIN
 
   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   VitalWireDelay(ad4_ipd, ad4, tipd_ad4);
   VitalWireDelay(ad5_ipd, ad5, tipd_ad5);
   VitalWireDelay(ad6_ipd, ad6, tipd_ad6);
   VitalWireDelay(ad7_ipd, ad7, tipd_ad7);
   END BLOCK;
 
   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ad0_ipd, ad1_ipd, ad2_ipd, ad3_ipd, ad4_ipd, ad5_ipd, ad6_ipd, ad7_ipd)
 
     VARIABLE memory   : std_logic_vector((2**8)-1 downto 0) := hex2bin(initval);
 
     -- functionality results
     VARIABLE do0_zd : std_logic :='X';
     
     -- output glitch results
     VARIABLE do0_GlitchData : VitalGlitchDataType;

BEGIN

   ------------------------
   -- functionality section
   ------------------------

      do0_zd := VitalMUX (data => memory,
                         dselect => (ad7_ipd, ad6_ipd, ad5_ipd, ad4_ipd, ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd));

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ad0_ipd'last_event, tpd_ad0_do0, TRUE),
               1 => (ad1_ipd'last_event, tpd_ad1_do0, TRUE),
               2 => (ad2_ipd'last_event, tpd_ad2_do0, TRUE),
               3 => (ad3_ipd'last_event, tpd_ad3_do0, TRUE),
               4 => (ad4_ipd'last_event, tpd_ad4_do0, TRUE),
               5 => (ad5_ipd'last_event, tpd_ad5_do0, TRUE),
               6 => (ad6_ipd'last_event, tpd_ad6_do0, TRUE),
               7 => (ad7_ipd'last_event, tpd_ad7_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn, 
      MsgOn => MsgOn);

   end process;
 
end V; 
 

--
----- cell rom128x1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem2.all;
 
-- entity declaration --
ENTITY rom128x1 IS
  GENERIC (
        initval : string := "0x00000000000000000000000000000000";
 
        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string  := "rom128x1";
 
        -- input SIGNAL delays
        tipd_ad0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad4  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad5  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad6  : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
 
 
        -- propagation delays
        tpd_ad0_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad1_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad2_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad3_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad4_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad5_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad6_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns));
 
  port (ad0  : IN   std_logic;
        ad1  : IN   std_logic;
        ad2  : IN   std_logic;
        ad3  : IN   std_logic;
        ad4  : IN   std_logic;
        ad5  : IN   std_logic;
        ad6  : IN   std_logic;
        do0   : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF rom128x1 : ENTITY IS TRUE;
 
END rom128x1;
 
-- architecture body --
ARCHITECTURE v OF rom128x1 IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL ad0_ipd  : std_logic := 'X';
   SIGNAL ad1_ipd  : std_logic := 'X';
   SIGNAL ad2_ipd  : std_logic := 'X';
   SIGNAL ad3_ipd  : std_logic := 'X';
   SIGNAL ad4_ipd  : std_logic := 'X';
   SIGNAL ad5_ipd  : std_logic := 'X';
   SIGNAL ad6_ipd  : std_logic := 'X';
 
BEGIN
 
   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   VitalWireDelay(ad4_ipd, ad4, tipd_ad4);
   VitalWireDelay(ad5_ipd, ad5, tipd_ad5);
   VitalWireDelay(ad6_ipd, ad6, tipd_ad6);
   END BLOCK;
 
   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ad0_ipd, ad1_ipd, ad2_ipd, ad3_ipd, ad4_ipd, ad5_ipd, ad6_ipd)
 
     VARIABLE memory   : std_logic_vector((2**7)-1 downto 0) := hex2bin(initval);
 
     -- functionality results
     VARIABLE do0_zd : std_logic :='X';
     
     -- output glitch results
     VARIABLE do0_GlitchData : VitalGlitchDataType;

BEGIN

   ------------------------
   -- functionality section
   ------------------------

      do0_zd := VitalMUX (data => memory,
                         dselect => (ad6_ipd, ad5_ipd, ad4_ipd, ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd));

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ad0_ipd'last_event, tpd_ad0_do0, TRUE),
               1 => (ad1_ipd'last_event, tpd_ad1_do0, TRUE),
               2 => (ad2_ipd'last_event, tpd_ad2_do0, TRUE),
               3 => (ad3_ipd'last_event, tpd_ad3_do0, TRUE),
               4 => (ad4_ipd'last_event, tpd_ad4_do0, TRUE),
               5 => (ad5_ipd'last_event, tpd_ad5_do0, TRUE),
               6 => (ad6_ipd'last_event, tpd_ad6_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn, 
      MsgOn => MsgOn);

   end process;
 
end V; 
 


--
----- cell rom64x1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem2.all;
 
-- entity declaration --
ENTITY rom64x1 IS
  GENERIC (
        initval : string := "0x0000000000000000";
 
        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string  := "rom64x1";
 
        -- input SIGNAL delays
        tipd_ad0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad4  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad5  : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
 
 
        -- propagation delays
        tpd_ad0_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad1_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad2_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad3_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad4_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad5_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns));
 
  port (ad0  : IN   std_logic;
        ad1  : IN   std_logic;
        ad2  : IN   std_logic;
        ad3  : IN   std_logic;
        ad4  : IN   std_logic;
        ad5  : IN   std_logic;
        do0   : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF rom64x1 : ENTITY IS TRUE;
 
END rom64x1;
 
-- architecture body --
ARCHITECTURE v OF rom64x1 IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL ad0_ipd  : std_logic := 'X';
   SIGNAL ad1_ipd  : std_logic := 'X';
   SIGNAL ad2_ipd  : std_logic := 'X';
   SIGNAL ad3_ipd  : std_logic := 'X';
   SIGNAL ad4_ipd  : std_logic := 'X';
   SIGNAL ad5_ipd  : std_logic := 'X';
 
BEGIN
 
   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   VitalWireDelay(ad4_ipd, ad4, tipd_ad4);
   VitalWireDelay(ad5_ipd, ad5, tipd_ad5);
   END BLOCK;
 
   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ad0_ipd, ad1_ipd, ad2_ipd, ad3_ipd, ad4_ipd, ad5_ipd)
 
     VARIABLE memory   : std_logic_vector((2**6)-1 downto 0) := hex2bin(initval);
 
     -- functionality results
     VARIABLE do0_zd : std_logic :='X';
     
     -- output glitch results
     VARIABLE do0_GlitchData : VitalGlitchDataType;

BEGIN

   ------------------------
   -- functionality section
   ------------------------

      do0_zd := VitalMUX (data => memory,
                         dselect => (ad5_ipd, ad4_ipd, ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd));

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ad0_ipd'last_event, tpd_ad0_do0, TRUE),
               1 => (ad1_ipd'last_event, tpd_ad1_do0, TRUE),
               2 => (ad2_ipd'last_event, tpd_ad2_do0, TRUE),
               3 => (ad3_ipd'last_event, tpd_ad3_do0, TRUE),
               4 => (ad4_ipd'last_event, tpd_ad4_do0, TRUE),
               5 => (ad5_ipd'last_event, tpd_ad5_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn, 
      MsgOn => MsgOn);

   end process;
 
end V; 
 


--
----- cell rom32x1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem2.all;
 
-- entity declaration --
ENTITY rom32x1 IS
  GENERIC (
        initval : string := "0x00000000";
 
        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := FALSE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := FALSE;
        InstancePath    : string  := "rom32x1";
 
        -- input SIGNAL delays
        tipd_ad0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad4  : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
 
 
        -- propagation delays
        tpd_ad0_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad1_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad2_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad3_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad4_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns));
 
  port (ad0  : IN   std_logic;
        ad1  : IN   std_logic;
        ad2  : IN   std_logic;
        ad3  : IN   std_logic;
        ad4  : IN   std_logic;
        do0   : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF rom32x1 : ENTITY IS TRUE;
 
END rom32x1;
 
-- architecture body --
ARCHITECTURE v OF rom32x1 IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL ad0_ipd  : std_logic := 'X';
   SIGNAL ad1_ipd  : std_logic := 'X';
   SIGNAL ad2_ipd  : std_logic := 'X';
   SIGNAL ad3_ipd  : std_logic := 'X';
   SIGNAL ad4_ipd  : std_logic := 'X';
 
BEGIN
 
   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   VitalWireDelay(ad4_ipd, ad4, tipd_ad4);
   END BLOCK;
 
   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ad0_ipd, ad1_ipd, ad2_ipd, ad3_ipd, ad4_ipd)
 
     VARIABLE memory   : std_logic_vector((2**5)-1 downto 0) := hex2bin(initval);
 
     -- functionality results
     VARIABLE do0_zd : std_logic :='X';
     
     -- output glitch results
     VARIABLE do0_GlitchData : VitalGlitchDataType;

BEGIN

   ------------------------
   -- functionality section
   ------------------------

      do0_zd := VitalMUX (data => memory,
                         dselect => (ad4_ipd, ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd));

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ad0_ipd'last_event, tpd_ad0_do0, TRUE),
               1 => (ad1_ipd'last_event, tpd_ad1_do0, TRUE),
               2 => (ad2_ipd'last_event, tpd_ad2_do0, TRUE),
               3 => (ad3_ipd'last_event, tpd_ad3_do0, TRUE),
               4 => (ad4_ipd'last_event, tpd_ad4_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn, 
      MsgOn => MsgOn);

   end process;
 
end V; 
 


--
----- cell rom16x1 -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem2.all;
 
-- entity declaration --
ENTITY rom16x1 IS
  GENERIC (
        initval : string := "0x0000";
 
        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath    : string  := "rom16x1";

        -- input SIGNAL delays
        tipd_ad0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3  : VitalDelayType01 := (0.0 ns, 0.0 ns);
 
 
 
        -- propagation delays
        tpd_ad0_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad1_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad2_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns);
        tpd_ad3_do0     : VitalDelayType01 := (0.01 ns, 0.01 ns));
 
  port (ad0  : IN   std_logic;
        ad1  : IN   std_logic;
        ad2  : IN   std_logic;
        ad3  : IN   std_logic;
        do0   : OUT  std_logic);
 
    ATTRIBUTE Vital_Level0 OF rom16x1 : ENTITY IS TRUE;
 
END rom16x1;

-- architecture body --
ARCHITECTURE v OF rom16x1 IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;
 
   SIGNAL ad0_ipd  : std_logic := 'X';
   SIGNAL ad1_ipd  : std_logic := 'X';
   SIGNAL ad2_ipd  : std_logic := 'X';
   SIGNAL ad3_ipd  : std_logic := 'X';
 
BEGIN
 
   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   END BLOCK;
 
   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ad0_ipd, ad1_ipd, ad2_ipd, ad3_ipd)
 
     VARIABLE memory   : std_logic_vector((2**4)-1 downto 0) := hex2bin(initval);
 
     -- functionality results
     VARIABLE do0_zd : std_logic :='X';
 
     -- output glitch results
     VARIABLE do0_GlitchData : VitalGlitchDataType;
 
BEGIN
 
   ------------------------
   -- functionality section
   ------------------------
 
      do0_zd := VitalMUX (data => memory,
                         dselect => (ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd));
 
   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ad0_ipd'last_event, tpd_ad0_do0, TRUE),
               1 => (ad1_ipd'last_event, tpd_ad1_do0, TRUE),
               2 => (ad2_ipd'last_event, tpd_ad2_do0, TRUE),
               3 => (ad3_ipd'last_event, tpd_ad3_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn,
      MsgOn => MsgOn);
 
   end process;
 
end V;

----- cell dpr16x2b -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem1.all;
USE work.global.gsrnet;
USE work.global.purnet;

-- entity declaration --
ENTITY dpr16x2b IS
  GENERIC (

        disabled_gsr  : Integer := 0;

        initval : string := "0x0000000000000000";

        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath    : string  := "dpr16x2b";

        -- input SIGNAL delays
        tipd_rad0 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_rad1 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_rad2 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_rad3 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wad0 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wad1 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wad2 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wad3 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_di0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_di1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wre  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wck  : VitalDelayType01 := (0.0 ns, 0.0 ns);

        -- setup and hold constraints
        tsetup_wad0_wck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_wad1_wck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_wad2_wck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_wad3_wck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_wre_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        tsetup_di0_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        tsetup_di1_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wad0_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wad1_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wad2_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wad3_wck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wre_wck_noedge_posedge   : VitalDelayType := 0.0 ns;
        thold_di0_wck_noedge_posedge   : VitalDelayType := 0.0 ns;
        thold_di1_wck_noedge_posedge   : VitalDelayType := 0.0 ns;

        -- pulse width constraints
        tperiod_wre             : VitalDelayType := 0.001 ns;
        tpw_wre_posedge : VitalDelayType := 0.001 ns;
        tpw_wre_negedge : VitalDelayType := 0.001 ns;
        tperiod_wck              : VitalDelayType := 0.001 ns;
        tpw_wck_posedge         : VitalDelayType := 0.001 ns;
        tpw_wck_negedge         : VitalDelayType := 0.001 ns;

        -- propagation delays
        tpd_wck_wdo0    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_wck_wdo1    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad0_rdo0    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad1_rdo0   : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad2_rdo0    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad3_rdo0    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad0_rdo1    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad1_rdo1   : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad2_rdo1    : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_rad3_rdo1    : VitalDelayType01 := (0.001 ns, 0.001 ns));

  port (di0  : IN std_logic;
        di1  : IN std_logic;
        wck  : IN std_logic;
        wre  : IN std_logic;
        rad0 : IN std_logic;
        rad1 : IN std_logic;
        rad2 : IN std_logic;
        rad3 : IN std_logic;
        wad0 : IN std_logic;
        wad1 : IN std_logic;
        wad2 : IN std_logic;
        wad3 : IN std_logic;
        wdo0 : OUT std_logic;
        wdo1 : OUT std_logic;
        rdo0 : OUT std_logic;
        rdo1 : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF dpr16x2b : ENTITY IS TRUE;

END dpr16x2b;


-- architecture body --
ARCHITECTURE v OF dpr16x2b IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL di0_ipd  : std_logic := 'X';
   SIGNAL di1_ipd  : std_logic := 'X';
   SIGNAL rad0_ipd : std_logic := 'X';
   SIGNAL rad1_ipd : std_logic := 'X';
   SIGNAL rad2_ipd : std_logic := 'X';
   SIGNAL rad3_ipd : std_logic := 'X';
   SIGNAL wad0_ipd : std_logic := 'X';
   SIGNAL wad1_ipd : std_logic := 'X';
   SIGNAL wad2_ipd : std_logic := 'X';
   SIGNAL wad3_ipd : std_logic := 'X';
   SIGNAL wre_ipd  : std_logic := 'X';
   SIGNAL wck_ipd  : std_logic := 'X';

BEGIN

   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(di0_ipd, di0, tipd_di0);
   VitalWireDelay(di1_ipd, di1, tipd_di1);
   VitalWireDelay(rad0_ipd, rad0, tipd_rad0);
   VitalWireDelay(rad1_ipd, rad1, tipd_rad1);
   VitalWireDelay(rad2_ipd, rad2, tipd_rad2);
   VitalWireDelay(rad3_ipd, rad3, tipd_rad3);
   VitalWireDelay(wad0_ipd, wad0, tipd_wad0);
   VitalWireDelay(wad1_ipd, wad1, tipd_wad1);
   VitalWireDelay(wad2_ipd, wad2, tipd_wad2);
   VitalWireDelay(wad3_ipd, wad3, tipd_wad3);
   VitalWireDelay(wre_ipd, wre, tipd_wre);
   VitalWireDelay(wck_ipd, wck, tipd_wck);
   END BLOCK;

   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (wck_ipd, wre_ipd, wad0_ipd,
     wad1_ipd, wad2_ipd, wad3_ipd, rad0_ipd, rad1_ipd, rad2_ipd,
     rad3_ipd, di0_ipd, di1_ipd, gsrnet, purnet)

     VARIABLE memory : mem_type_2 ((2**4)-1 downto 0) := init_ram(initval);
     VARIABLE radr_reg, wadr_reg, wadr_reg1 : std_logic_vector(3 downto 0) := "0000";
     VARIABLE din_reg : std_logic_vector(1 downto 0) := "00";
     VARIABLE wre_reg : std_logic := '0';
     VARIABLE rindex, windex, windex1 : integer := 0;
     VARIABLE set_reset : std_logic := '1';

     -- timing check results
     VARIABLE tviol_di0   : x01 := '0';
     VARIABLE tviol_di1   : x01 := '0';
     VARIABLE tviol_wad0  : x01 := '0';
     VARIABLE tviol_wad1  : x01 := '0';
     VARIABLE tviol_wad2  : x01 := '0';
     VARIABLE tviol_wad3  : x01 := '0';
     VARIABLE tviol_wre  : x01 := '0';
     VARIABLE tsviol_wre : x01 := '0';
     VARIABLE tviol_wck    : x01 := '0';
     VARIABLE PeriodCheckInfo_wre : VitalPeriodDataType;
     VARIABLE PeriodCheckInfo_wck   : VitalPeriodDataType;
     VARIABLE wad0_wck_TimingDatash : VitalTimingDataType;
     VARIABLE wad1_wck_TimingDatash : VitalTimingDataType;
     VARIABLE wad2_wck_TimingDatash : VitalTimingDataType;
     VARIABLE wad3_wck_TimingDatash : VitalTimingDataType;
     VARIABLE wre_wck_TimingDatash : VitalTimingDataType;
     VARIABLE di0_wck_TimingDatash  : VitalTimingDataType;
     VARIABLE di1_wck_TimingDatash  : VitalTimingDataType;

     -- functionality results
     VARIABLE violation : x01 := '0';
     VARIABLE results   : std_logic_vector (3 downto 0) := (others => 'X');
     ALIAS wdo0_zd       : std_ulogic IS results(0);
     ALIAS wdo1_zd       : std_ulogic IS results(1);
     ALIAS rdo0_zd       : std_ulogic IS results(2);
     ALIAS rdo1_zd       : std_ulogic IS results(3);

     -- output glitch results
     VARIABLE wdo0_GlitchData  : VitalGlitchDataType;
     VARIABLE wdo1_GlitchData  : VitalGlitchDataType;
     VARIABLE rdo0_GlitchData  : VitalGlitchDataType;
     VARIABLE rdo1_GlitchData  : VitalGlitchDataType;

   BEGIN

   -----------------------
   -- timing check section
   -----------------------
        IF (TimingChecksOn) THEN

           -- setup and hold checks on the write address lines
           VitalSetupHoldCheck (
                TestSignal => wad0_ipd,
                TestSignalName => "wad0",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_wad0_wck_noedge_posedge,
                setuplow => tsetup_wad0_wck_noedge_posedge,
                HoldHigh => thold_wad0_wck_noedge_posedge,
                HoldLow => thold_wad0_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wad0_wck_timingdatash,
                Violation => tviol_wad0,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => wad1_ipd,
                TestSignalName => "wad1",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_wad1_wck_noedge_posedge,
                setuplow => tsetup_wad1_wck_noedge_posedge,
                HoldHigh => thold_wad1_wck_noedge_posedge,
                HoldLow =>  thold_wad1_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wad1_wck_timingdatash,
                Violation => tviol_wad1,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => wad2_ipd,
                TestSignalName => "wad2",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_wad2_wck_noedge_posedge,
                setuplow => tsetup_wad2_wck_noedge_posedge,
                HoldHigh => thold_wad2_wck_noedge_posedge,
                HoldLow => thold_wad2_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wad2_wck_timingdatash,
                Violation => tviol_wad2,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => wad3_ipd,
                TestSignalName => "wad3",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_wad3_wck_noedge_posedge,
                setuplow => tsetup_wad3_wck_noedge_posedge,
                HoldHigh => thold_wad3_wck_noedge_posedge,
                HoldLow => thold_wad3_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wad3_wck_timingdatash,
                Violation => tviol_wad3,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => wre_ipd,
                TestSignalName => "wre",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_wre_wck_noedge_posedge,
                setuplow => tsetup_wre_wck_noedge_posedge,
                HoldHigh => thold_wre_wck_noedge_posedge,
                HoldLow => thold_wre_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wre_wck_timingdatash,
                Violation => tsviol_wre,
                MsgSeverity => warning);
           -- setup and hold checks on data
           VitalSetupHoldCheck (
                TestSignal => di0_ipd,
                TestSignalName => "di0",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_di0_wck_noedge_posedge,
                setuplow => tsetup_di0_wck_noedge_posedge,
                HoldHigh => thold_di0_wck_noedge_posedge,
                HoldLow => thold_di0_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => di0_wck_timingdatash,
                Violation => tviol_di0,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => di1_ipd,
                TestSignalName => "di1",
                RefSignal => wck_ipd,
                RefSignalName => "wck",
                SetupHigh => tsetup_di1_wck_noedge_posedge,
                setuplow => tsetup_di1_wck_noedge_posedge,
                HoldHigh => thold_di1_wck_noedge_posedge,
                HoldLow => thold_di1_wck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => di1_wck_timingdatash,
                Violation => tviol_di1,
                MsgSeverity => warning);

           -- Period and pulse width checks on write and port enables
           VitalPeriodPulseCheck (
               TestSignal => wck_ipd,
               TestSignalName => "wck",
               Period => tperiod_wck,
               PulseWidthHigh => tpw_wck_posedge,
               PulseWidthLow => tpw_wck_posedge,
               Perioddata => periodcheckinfo_wck,
               Violation => tviol_wck,
               MsgOn => MsgOn, XOn => XOn,
               HeaderMsg => InstancePath,
               CheckEnabled => TRUE,
               MsgSeverity => warning);
           VitalPeriodPulseCheck (
               TestSignal => wre_ipd,
               TestSignalName => "wre",
               Period => tperiod_wre,
               PulseWidthHigh => tpw_wre_posedge,
               PulseWidthLow => tpw_wre_posedge,
               Perioddata => periodcheckinfo_wre,
               Violation => tviol_wre,
               MsgOn => MsgOn, XOn => XOn,
               HeaderMsg => InstancePath,
               CheckEnabled => TRUE,
               MsgSeverity => warning);
        END IF;

   ------------------------
   -- functionality section
   ------------------------
--    IF (disabled_gsr =  1) THEN
--       set_reset := purnet;
--    ELSE
--       set_reset := purnet AND gsrnet;
--    END IF;

--   IF (set_reset= '0') THEN
--      wre_reg := '0';
--      wadr_reg := "0000";
--   END IF;

   Violation := tviol_di0 or tviol_di1 or tviol_wad0 or tviol_wad1 or tviol_wad2 or
                tviol_wad3 or tviol_wre or tviol_wck or tsviol_wre ;


   IF ((is_x(wre_ipd)) and (set_reset='1')) THEN
      assert FALSE
        report "dpr16x2b memory hazard write enable unknown!"
        severity warning;
      results := (others => 'X');
   ELSIF (is_x(rad0_ipd) or is_x(rad1_ipd) or is_x(rad2_ipd)
        or is_x(rad3_ipd)) THEN
      assert FALSE
        report "dpr16x2b memory hazard read address unknown!"
        severity warning;
      results := (others => 'X');
   ELSIF ((is_x(wad0_ipd) or is_x(wad1_ipd) or is_x(wad2_ipd)
        or is_x(wad3_ipd)) and (set_reset='1')) THEN
      assert FALSE
        report "dpr16x2b memory hazard write address unknown!"
        severity warning;
      results := (others => 'X');
   ELSE
      -- register the write address, write enables and data but not the
      -- read address
      IF ((wck_ipd'event and wck_ipd = '1') and (set_reset= '1')) THEN
         wre_reg := (wre_ipd);
         din_reg := (di1_ipd, di0_ipd);
         wadr_reg := (wad3_ipd, wad2_ipd, wad1_ipd, wad0_ipd);
      END IF;
      windex := conv_integer(wadr_reg);
      radr_reg := (rad3_ipd, rad2_ipd, rad1_ipd, rad0_ipd);
      rindex := conv_integer(radr_reg);
      wadr_reg1 := (wad3_ipd, wad2_ipd, wad1_ipd, wad0_ipd);
      windex1 := conv_integer(wadr_reg1);

      -- at the falling edge of wck, write to memory at address
      IF (wre_reg = '1') THEN
         IF (wck_ipd'event and wck_ipd = '1') THEN
             memory(windex) := din_reg;
         END IF;
      END IF;

      -- asynchronous and synchronous reads
      IF (violation = '0') THEN
         results(3 downto 2) := memory(rindex);
         results(1 downto 0) := memory(windex1);
      ELSE
         results := (others => 'X');
      END IF;
 
   END IF;

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => wdo0,
     OutSignalName => "wdo0",
     OutTemp => wdo0_zd,
     Paths => (0 => (wck_ipd'last_event, tpd_wck_wdo0, TRUE)),
      GlitchData => wdo0_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);
   VitalPathDelay01 (
     OutSignal => wdo1,
     OutSignalName => "wdo1",
     OutTemp => wdo1_zd,
     Paths => (0 => (wck_ipd'last_event, tpd_wck_wdo1, TRUE)),
      GlitchData => wdo1_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);
   VitalPathDelay01 (
     OutSignal => rdo0,
     OutSignalName => "rdo0",
     OutTemp => rdo0_zd,
     Paths => (0 => (rad0_ipd'last_event, tpd_rad0_rdo0, TRUE),
               1 => (rad1_ipd'last_event, tpd_rad1_rdo0, TRUE),
               2 => (rad2_ipd'last_event, tpd_rad2_rdo0, TRUE),
               3 => (rad3_ipd'last_event, tpd_rad3_rdo0, TRUE)),
      GlitchData => rdo0_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);
   VitalPathDelay01 (
     OutSignal => rdo1,
     OutSignalName => "rdo1",
     OutTemp => rdo1_zd,
     Paths => (0 => (rad0_ipd'last_event, tpd_rad0_rdo1, TRUE),
               1 => (rad1_ipd'last_event, tpd_rad1_rdo1, TRUE),
               2 => (rad2_ipd'last_event, tpd_rad2_rdo1, TRUE),
               3 => (rad3_ipd'last_event, tpd_rad3_rdo1, TRUE)),
      GlitchData => rdo1_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);

   END PROCESS;

END v;



--
----- cell spr16x2b -----
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.vital_timing.all;
USE ieee.vital_primitives.all;
USE work.mem1.all;
USE work.global.gsrnet;
USE work.global.purnet;

-- entity declaration --
ENTITY spr16x2b IS
  GENERIC (

        disabled_gsr  : Integer := 0;

        initval : string := "0x0000000000000000";

        -- miscellaneous vital GENERICs
        TimingChecksOn  : boolean := TRUE;
        XOn             : boolean := FALSE;
        MsgOn           : boolean := TRUE;
        InstancePath    : string  := "spr16x2b";

        -- input SIGNAL delays
        tipd_ad0 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad1 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad2 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ad3 : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_di0  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_di1  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_wre  : VitalDelayType01 := (0.0 ns, 0.0 ns);
        tipd_ck   : VitalDelayType01 := (0.0 ns, 0.0 ns);

        -- setup and hold constraints
        tsetup_ad0_ck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_ad1_ck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_ad2_ck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_ad3_ck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_wre_ck_noedge_posedge : VitalDelayType := 0.0 ns;
        tsetup_di0_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        tsetup_di1_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_ad0_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_ad1_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_ad2_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_ad3_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_wre_ck_noedge_posedge  : VitalDelayType := 0.0 ns;
        thold_di0_ck_noedge_posedge   : VitalDelayType := 0.0 ns;
        thold_di1_ck_noedge_posedge   : VitalDelayType := 0.0 ns;

        -- pulse width constraints
        tperiod_wre             : VitalDelayType := 0.001 ns;
        tpw_wre_posedge : VitalDelayType := 0.001 ns;
        tpw_wre_negedge : VitalDelayType := 0.001 ns;
        tperiod_ck              : VitalDelayType := 0.001 ns;
        tpw_ck_posedge          : VitalDelayType := 0.001 ns;
        tpw_ck_negedge          : VitalDelayType := 0.001 ns;

        -- propagation delays
        tpd_ck_do0     : VitalDelayType01 := (0.001 ns, 0.001 ns);
        tpd_ck_do1     : VitalDelayType01 := (0.001 ns, 0.001 ns));

  port (di0  : IN std_logic;
        di1  : IN std_logic;
        ck   : IN std_logic;
        wre  : IN std_logic;
        ad0  : IN std_logic;
        ad1  : IN std_logic;
        ad2  : IN std_logic;
        ad3  : IN std_logic;
        do0  : OUT std_logic;
        do1  : OUT std_logic);

    ATTRIBUTE Vital_Level0 OF spr16x2b : ENTITY IS TRUE;

END spr16x2b;


-- architecture body --
ARCHITECTURE v OF spr16x2b IS
    ATTRIBUTE Vital_Level0 OF v : ARCHITECTURE IS TRUE;

   SIGNAL di0_ipd  : std_logic := 'X';
   SIGNAL di1_ipd  : std_logic := 'X';
   SIGNAL ad0_ipd : std_logic := 'X';
   SIGNAL ad1_ipd : std_logic := 'X';
   SIGNAL ad2_ipd : std_logic := 'X';
   SIGNAL ad3_ipd : std_logic := 'X';
   SIGNAL wre_ipd : std_logic := 'X';
   SIGNAL ck_ipd   : std_logic := 'X';

BEGIN

   -----------------------
   -- input path delays
   -----------------------
   WireDelay : BLOCK
   BEGIN
   VitalWireDelay(di0_ipd, di0, tipd_di0);
   VitalWireDelay(di1_ipd, di1, tipd_di1);
   VitalWireDelay(ad0_ipd, ad0, tipd_ad0);
   VitalWireDelay(ad1_ipd, ad1, tipd_ad1);
   VitalWireDelay(ad2_ipd, ad2, tipd_ad2);
   VitalWireDelay(ad3_ipd, ad3, tipd_ad3);
   VitalWireDelay(wre_ipd, wre, tipd_wre);
   VitalWireDelay(ck_ipd, ck, tipd_ck);
   END BLOCK;

   -----------------------
   -- behavior section
   -----------------------
   VitalBehavior : PROCESS (ck_ipd, wre_ipd, ad0_ipd,
     ad1_ipd, ad2_ipd, ad3_ipd, di0_ipd, di1_ipd, gsrnet, purnet)

     VARIABLE memory : mem_type_2 ((2**4)-1 downto 0) := init_ram(initval);
     VARIABLE radr_reg, wadr_reg : std_logic_vector(3 downto 0) := "0000";
     VARIABLE din_reg : std_logic_vector(1 downto 0) := "00";
     VARIABLE wre_reg : std_logic := '0';
     VARIABLE rindex, windex : integer := 0;
     VARIABLE set_reset : std_logic := '1';

     -- timing check results
     VARIABLE tviol_di0   : x01 := '0';
     VARIABLE tviol_di1   : x01 := '0';
     VARIABLE tviol_ad0  : x01 := '0';
     VARIABLE tviol_ad1  : x01 := '0';
     VARIABLE tviol_ad2  : x01 := '0';
     VARIABLE tviol_ad3  : x01 := '0';
     VARIABLE tviol_wre  : x01 := '0';
     VARIABLE tsviol_wre : x01 := '0';
     VARIABLE tviol_ck    : x01 := '0';
     VARIABLE PeriodCheckInfo_wre : VitalPeriodDataType;
     VARIABLE PeriodCheckInfo_ck   : VitalPeriodDataType;
     VARIABLE ad0_ck_TimingDatash : VitalTimingDataType;
     VARIABLE ad1_ck_TimingDatash : VitalTimingDataType;
     VARIABLE ad2_ck_TimingDatash : VitalTimingDataType;
     VARIABLE ad3_ck_TimingDatash : VitalTimingDataType;
     VARIABLE wre_ck_TimingDatash : VitalTimingDataType;
     VARIABLE di0_ck_TimingDatash  : VitalTimingDataType;
     VARIABLE di1_ck_TimingDatash  : VitalTimingDataType;

     -- functionality results
     VARIABLE violation : x01 := '0';
     VARIABLE results   : std_logic_vector (1 downto 0) := (others => 'X');
     ALIAS do0_zd       : std_ulogic IS results(0);
     ALIAS do1_zd       : std_ulogic IS results(1);

     -- output glitch results
     VARIABLE do0_GlitchData  : VitalGlitchDataType;
     VARIABLE do1_GlitchData  : VitalGlitchDataType;

   BEGIN

   -----------------------
   -- timing check section
   -----------------------
        IF (TimingChecksOn) THEN

           -- setup and hold checks on the write address lines
           VitalSetupHoldCheck (
                TestSignal => ad0_ipd,
                TestSignalName => "ad0",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_ad0_ck_noedge_posedge,
                setuplow => tsetup_ad0_ck_noedge_posedge,
                HoldHigh => thold_ad0_ck_noedge_posedge,
                HoldLow => thold_ad0_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => ad0_ck_timingdatash,
                Violation => tviol_ad0,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => ad1_ipd,
                TestSignalName => "ad1",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_ad1_ck_noedge_posedge,
                setuplow => tsetup_ad1_ck_noedge_posedge,
                HoldHigh => thold_ad1_ck_noedge_posedge,
                HoldLow =>  thold_ad1_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => ad1_ck_timingdatash,
                Violation => tviol_ad1,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => ad2_ipd,
                TestSignalName => "ad2",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_ad2_ck_noedge_posedge,
                setuplow => tsetup_ad2_ck_noedge_posedge,
                HoldHigh => thold_ad2_ck_noedge_posedge,
                HoldLow => thold_ad2_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => ad2_ck_timingdatash,
                Violation => tviol_ad2,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => ad3_ipd,
                TestSignalName => "ad3",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_ad3_ck_noedge_posedge,
                setuplow => tsetup_ad3_ck_noedge_posedge,
                HoldHigh => thold_ad3_ck_noedge_posedge,
                HoldLow => thold_ad3_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => ad3_ck_timingdatash,
                Violation => tviol_ad3,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => wre_ipd,
                TestSignalName => "wre",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_wre_ck_noedge_posedge,
                setuplow => tsetup_wre_ck_noedge_posedge,
                HoldHigh => thold_wre_ck_noedge_posedge,
                HoldLow => thold_wre_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => wre_ck_timingdatash,
                Violation => tsviol_wre,
                MsgSeverity => warning);
           -- setup and hold checks on data
           VitalSetupHoldCheck (
                TestSignal => di0_ipd,
                TestSignalName => "di0",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_di0_ck_noedge_posedge,
                setuplow => tsetup_di0_ck_noedge_posedge,
                HoldHigh => thold_di0_ck_noedge_posedge,
                HoldLow => thold_di0_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => di0_ck_timingdatash,
                Violation => tviol_di0,
                MsgSeverity => warning);
           VitalSetupHoldCheck (
                TestSignal => di1_ipd,
                TestSignalName => "di1",
                RefSignal => ck_ipd,
                RefSignalName => "ck",
                SetupHigh => tsetup_di1_ck_noedge_posedge,
                setuplow => tsetup_di1_ck_noedge_posedge,
                HoldHigh => thold_di1_ck_noedge_posedge,
                HoldLow => thold_di1_ck_noedge_posedge,
                CheckEnabled => (set_reset='1'),
                RefTransition => '/',
                MsgOn => MsgOn, XOn => XOn,
                HeaderMsg => InstancePath,
                TimingData => di1_ck_timingdatash,
                Violation => tviol_di1,
                MsgSeverity => warning);

           -- Period and pulse width checks on write and port enables
           VitalPeriodPulseCheck (
               TestSignal => ck_ipd,
               TestSignalName => "ck",
               Period => tperiod_ck,
               PulseWidthHigh => tpw_ck_posedge,
               PulseWidthLow => tpw_ck_posedge,
               Perioddata => periodcheckinfo_ck,
               Violation => tviol_ck,
               MsgOn => MsgOn, XOn => XOn,
               HeaderMsg => InstancePath,
               CheckEnabled => TRUE,
               MsgSeverity => warning);
           VitalPeriodPulseCheck (
               TestSignal => wre_ipd,
               TestSignalName => "wre",
               Period => tperiod_wre,
               PulseWidthHigh => tpw_wre_posedge,
               PulseWidthLow => tpw_wre_posedge,
               Perioddata => periodcheckinfo_wre,
               Violation => tviol_wre,
               MsgOn => MsgOn, XOn => XOn,
               HeaderMsg => InstancePath,
               CheckEnabled => TRUE,
               MsgSeverity => warning);
        END IF;

   ------------------------
   -- functionality section
   ------------------------
 --   IF (disabled_gsr =  1) THEN
 --      set_reset := purnet;
 --   ELSE
 --      set_reset := purnet AND gsrnet;
 --   END IF;

 --  IF (set_reset= '0') THEN
 --     wre_reg := '0';
 --     wadr_reg := "0000";
 --  END IF;

   Violation := tviol_di0 or tviol_di0 or tviol_ad0 or tviol_ad1 or tviol_ad2 or
                tviol_ad3 or tviol_wre or tviol_ck or tsviol_wre;


   IF ((is_x(wre_ipd)) and (set_reset='1')) THEN
      assert FALSE
        report "spr16x2b memory hazard write enable unknown!"
        severity warning;
      results := (others => 'X');
   ELSIF (is_x(ad0_ipd) or is_x(ad1_ipd) or is_x(ad2_ipd)
        or is_x(ad3_ipd)) THEN
      assert FALSE
        report "spr16x2b memory hazard read address unknown!"
        severity warning;
      results := (others => 'X');
   ELSE
      -- register the write address, write enables and data but not the
      -- read address
      IF ((ck_ipd'event and ck_ipd = '1') and (set_reset= '1')) THEN
         wre_reg := (wre_ipd);
         din_reg := (di1_ipd, di0_ipd);
         wadr_reg := (ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd);
      END IF;
      windex := conv_integer(wadr_reg);
      radr_reg := (ad3_ipd, ad2_ipd, ad1_ipd, ad0_ipd);
      rindex := conv_integer(radr_reg);

      -- at the falling edge of ck, write to memory at address
      IF (wre_reg = '1') THEN
         IF (ck_ipd'event and ck_ipd = '1') THEN
             memory(windex) := din_reg;
         END IF;
      END IF;

      -- asynchronous and synchronous reads
      IF (violation = '0') THEN
         results(1 downto 0) := memory(rindex);
      ELSE
         results := (others => 'X');
      END IF;
 
   END IF;

   ------------------------
   -- path delay section
   ------------------------
   VitalPathDelay01 (
     OutSignal => do0,
     OutSignalName => "do0",
     OutTemp => do0_zd,
     Paths => (0 => (ck_ipd'last_event, tpd_ck_do0, TRUE)),
      GlitchData => do0_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);
   VitalPathDelay01 (
     OutSignal => do1,
     OutSignalName => "do1",
     OutTemp => do1_zd,
     Paths => (0 => (ck_ipd'last_event, tpd_ck_do1, TRUE)),
      GlitchData => do1_glitchdata,
      Mode => ondetect,
      XOn => XOn, MsgOn => MsgOn);

   END PROCESS;

END v;

----- CELL MULT18X18 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.VITAL_Timing.all;
use work.components.all;
use work.global.gsrnet;
use work.global.purnet;

-- entity declaration --
entity MULT18X18 is
  generic(
	 REG_INPUTA_CLK       : string     := "NONE";
	 REG_INPUTA_CE        : string     := "CE0";
	 REG_INPUTA_RST       : string     := "RST0";
	 REG_INPUTB_CLK       : string     := "NONE";
	 REG_INPUTB_CE        : string     := "CE0";
	 REG_INPUTB_RST       : string     := "RST0";
	 REG_PIPELINE_CLK     : string     := "NONE";
	 REG_PIPELINE_CE      : string     := "CE0";
	 REG_PIPELINE_RST     : string     := "RST0";
	 REG_OUTPUT_CLK       : string     := "NONE";
	 REG_OUTPUT_CE        : string     := "CE0";
	 REG_OUTPUT_RST       : string     := "RST0";
	 REG_SIGNEDAB_0_CLK   : string     := "NONE";
	 REG_SIGNEDAB_0_CE    : string     := "CE0";
	 REG_SIGNEDAB_0_RST   : string     := "RST0";
	 REG_SIGNEDAB_1_CLK   : string     := "NONE";
	 REG_SIGNEDAB_1_CE    : string     := "CE0";
	 REG_SIGNEDAB_1_RST   : string     := "RST0";
	 SHIFT_IN_A           : string     := "FALSE";
	 SHIFT_IN_B           : string     := "FALSE";
	 GSR                  : string     := "ENABLED");
  port (
        A0 : in STD_ULOGIC;
        A1 : in STD_ULOGIC;
        A2 : in STD_ULOGIC;
        A3 : in STD_ULOGIC;
        A4 : in STD_ULOGIC;
        A5 : in STD_ULOGIC;
        A6 : in STD_ULOGIC;
        A7 : in STD_ULOGIC;
        A8 : in STD_ULOGIC;
        A9 : in STD_ULOGIC;
        A10 : in STD_ULOGIC;
        A11 : in STD_ULOGIC;
        A12 : in STD_ULOGIC;
        A13 : in STD_ULOGIC;
        A14 : in STD_ULOGIC;
        A15 : in STD_ULOGIC;
        A16 : in STD_ULOGIC;
        A17 : in STD_ULOGIC;

        SRIA0 : in STD_ULOGIC;
        SRIA1 : in STD_ULOGIC;
        SRIA2 : in STD_ULOGIC;
        SRIA3 : in STD_ULOGIC;
        SRIA4 : in STD_ULOGIC;
        SRIA5 : in STD_ULOGIC;
        SRIA6 : in STD_ULOGIC;
        SRIA7 : in STD_ULOGIC;
        SRIA8 : in STD_ULOGIC;
        SRIA9 : in STD_ULOGIC;
        SRIA10 : in STD_ULOGIC;
        SRIA11 : in STD_ULOGIC;
        SRIA12 : in STD_ULOGIC;
        SRIA13 : in STD_ULOGIC;
        SRIA14 : in STD_ULOGIC;
        SRIA15 : in STD_ULOGIC;
        SRIA16 : in STD_ULOGIC;
        SRIA17 : in STD_ULOGIC;

        B0 : in STD_ULOGIC;
        B1 : in STD_ULOGIC;
        B2 : in STD_ULOGIC;
        B3 : in STD_ULOGIC;
        B4 : in STD_ULOGIC;
        B5 : in STD_ULOGIC;
        B6 : in STD_ULOGIC;
        B7 : in STD_ULOGIC;
        B8 : in STD_ULOGIC;
        B9 : in STD_ULOGIC;
        B10 : in STD_ULOGIC;
        B11 : in STD_ULOGIC;
        B12 : in STD_ULOGIC;
        B13 : in STD_ULOGIC;
        B14 : in STD_ULOGIC;
        B15 : in STD_ULOGIC;
        B16 : in STD_ULOGIC;
        B17 : in STD_ULOGIC;

        SRIB0 : in STD_ULOGIC;
        SRIB1 : in STD_ULOGIC;
        SRIB2 : in STD_ULOGIC;
        SRIB3 : in STD_ULOGIC;
        SRIB4 : in STD_ULOGIC;
        SRIB5 : in STD_ULOGIC;
        SRIB6 : in STD_ULOGIC;
        SRIB7 : in STD_ULOGIC;
        SRIB8 : in STD_ULOGIC;
        SRIB9 : in STD_ULOGIC;
        SRIB10 : in STD_ULOGIC;
        SRIB11 : in STD_ULOGIC;
        SRIB12 : in STD_ULOGIC;
        SRIB13 : in STD_ULOGIC;
        SRIB14 : in STD_ULOGIC;
        SRIB15 : in STD_ULOGIC;
        SRIB16 : in STD_ULOGIC;
        SRIB17 : in STD_ULOGIC;

        SIGNEDAB : in STD_ULOGIC;

        CE0 : in STD_ULOGIC;
        CE1 : in STD_ULOGIC;
        CE2 : in STD_ULOGIC;
        CE3 : in STD_ULOGIC;

        CLK0 : in STD_ULOGIC;
        CLK1 : in STD_ULOGIC;
        CLK2 : in STD_ULOGIC;
        CLK3 : in STD_ULOGIC;

        RST0 : in STD_ULOGIC;
        RST1 : in STD_ULOGIC;
        RST2 : in STD_ULOGIC;
        RST3 : in STD_ULOGIC;

        SROA0 : out STD_ULOGIC;
        SROA1 : out STD_ULOGIC;
        SROA2 : out STD_ULOGIC;
        SROA3 : out STD_ULOGIC;
        SROA4 : out STD_ULOGIC;
        SROA5 : out STD_ULOGIC;
        SROA6 : out STD_ULOGIC;
        SROA7 : out STD_ULOGIC;
        SROA8 : out STD_ULOGIC;
        SROA9 : out STD_ULOGIC;
        SROA10 : out STD_ULOGIC;
        SROA11 : out STD_ULOGIC;
        SROA12 : out STD_ULOGIC;
        SROA13 : out STD_ULOGIC;
        SROA14 : out STD_ULOGIC;
        SROA15 : out STD_ULOGIC;
        SROA16 : out STD_ULOGIC;
        SROA17 : out STD_ULOGIC;

        SROB0 : out STD_ULOGIC;
        SROB1 : out STD_ULOGIC;
        SROB2 : out STD_ULOGIC;
        SROB3 : out STD_ULOGIC;
        SROB4 : out STD_ULOGIC;
        SROB5 : out STD_ULOGIC;
        SROB6 : out STD_ULOGIC;
        SROB7 : out STD_ULOGIC;
        SROB8 : out STD_ULOGIC;
        SROB9 : out STD_ULOGIC;
        SROB10 : out STD_ULOGIC;
        SROB11 : out STD_ULOGIC;
        SROB12 : out STD_ULOGIC;
        SROB13 : out STD_ULOGIC;
        SROB14 : out STD_ULOGIC;
        SROB15 : out STD_ULOGIC;
        SROB16 : out STD_ULOGIC;
        SROB17 : out STD_ULOGIC;

        P0 : out STD_ULOGIC;
        P1 : out STD_ULOGIC;
        P2 : out STD_ULOGIC;
        P3 : out STD_ULOGIC;
        P4 : out STD_ULOGIC;
        P5 : out STD_ULOGIC;
        P6 : out STD_ULOGIC;
        P7 : out STD_ULOGIC;
        P8 : out STD_ULOGIC;
        P9 : out STD_ULOGIC;
        P10 : out STD_ULOGIC;
        P11 : out STD_ULOGIC;
        P12 : out STD_ULOGIC;
        P13 : out STD_ULOGIC;
        P14 : out STD_ULOGIC;
        P15 : out STD_ULOGIC;
        P16 : out STD_ULOGIC;
        P17 : out STD_ULOGIC;
        P18 : out STD_ULOGIC;
        P19 : out STD_ULOGIC;
        P20 : out STD_ULOGIC;
        P21 : out STD_ULOGIC;
        P22 : out STD_ULOGIC;
        P23 : out STD_ULOGIC;
        P24 : out STD_ULOGIC;
        P25 : out STD_ULOGIC;
        P26 : out STD_ULOGIC;
        P27 : out STD_ULOGIC;
        P28 : out STD_ULOGIC;
        P29 : out STD_ULOGIC;
        P30 : out STD_ULOGIC;
        P31 : out STD_ULOGIC;
        P32 : out STD_ULOGIC;
        P33 : out STD_ULOGIC;
        P34 : out STD_ULOGIC;
        P35 : out STD_ULOGIC
       ); 

attribute VITAL_LEVEL0 of MULT18X18 : entity is TRUE;

end MULT18X18;

--- Architecture 

library IEEE;
use IEEE.VITAL_Primitives.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
architecture V of MULT18X18 is

  attribute VITAL_LEVEL0 of V : architecture is TRUE;

  -- Local signals used to propagate input wire delay

  signal A_ipd     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal SRIA_ipd  : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal SROA_reg  : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal B_ipd     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal SRIB_ipd  : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal SROB_reg  : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal P_ipd     : std_logic_vector(35 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  signal SIGNEDAB_ipd : std_logic := 'X';
  signal CE0_ipd   : std_logic := 'X';
  signal CE1_ipd   : std_logic := 'X';
  signal CE2_ipd   : std_logic := 'X';
  signal CE3_ipd   : std_logic := 'X';
  signal CLK0_ipd  : std_logic := 'X';
  signal CLK1_ipd  : std_logic := 'X';
  signal CLK2_ipd  : std_logic := 'X';
  signal CLK3_ipd  : std_logic := 'X';
  signal RST0_ipd  : std_logic := 'X';
  signal RST1_ipd  : std_logic := 'X';
  signal RST2_ipd  : std_logic := 'X';
  signal RST3_ipd  : std_logic := 'X';

  signal A_reg     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal B_reg     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal A_p       : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal B_p       : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal A_gen     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal B_gen     : std_logic_vector(17 downto 0) := "XXXXXXXXXXXXXXXXXX";
  signal P_i       : std_logic_vector(35 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  signal P_o       : std_logic_vector(35 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  signal P_ps      : std_logic_vector(35 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  signal P_o1      : std_logic_vector(35 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

  signal input_a_clk  : std_logic := 'X';
  signal input_a_ce   : std_logic := 'X';
  signal input_a_rst  : std_logic := 'X';
  signal input_b_clk  : std_logic := 'X';
  signal input_b_ce   : std_logic := 'X';
  signal input_b_rst  : std_logic := 'X';
  signal pipeline_clk : std_logic := 'X';
  signal pipeline_ce  : std_logic := 'X';
  signal pipeline_rst : std_logic := 'X';
  signal output_clk   : std_logic := 'X';
  signal output_ce    : std_logic := 'X';
  signal output_rst   : std_logic := 'X';
  signal signedab_0_clk : std_logic := 'X';
  signal signedab_0_ce  : std_logic := 'X';
  signal signedab_0_rst  : std_logic := 'X';
  signal signedab_1_clk : std_logic := 'X';
  signal signedab_1_ce  : std_logic := 'X';
  signal signedab_1_rst  : std_logic := 'X';
  signal signedab_0_reg  : std_logic := 'X';
  signal signedab_1_reg  : std_logic := 'X';
  signal signedab_p1  : std_logic := 'X';
  signal signedab_p2  : std_logic := 'X';

  signal SRN          : std_logic;
  signal input_a_rst_ogsr  : std_logic := 'X';
  signal input_b_rst_ogsr  : std_logic := 'X';
  signal pipeline_rst_ogsr  : std_logic := 'X';
  signal output_rst_ogsr  : std_logic := 'X';
  signal signedab_0_rst_ogsr  : std_logic := 'X';
  signal signedab_1_rst_ogsr  : std_logic := 'X';

begin 

    global_reset : process (purnet, gsrnet)
      begin
        if (GSR =  "DISABLED") then
           SRN <= purnet;
        else
           SRN <= purnet AND gsrnet;
        end if;
      end process;

    input_a_rst_ogsr <= input_a_rst or not SRN;
    input_b_rst_ogsr <= input_b_rst or not SRN;
    pipeline_rst_ogsr <= pipeline_rst or not SRN;
    output_rst_ogsr <= output_rst or not SRN;
    signedab_0_rst_ogsr <= signedab_0_rst or not SRN;
    signedab_1_rst_ogsr <= signedab_1_rst or not SRN;

    A_ipd <= (A17 & A16 & A15 & A14 & A13 & A12 & A11 & A10 & A9 & A8 & A7 & A6 & A5 & A4 & A3 & A2 & A1 & A0); 
    B_ipd <= (B17 & B16 & B15 & B14 & B13 & B12 & B11 & B10 & B9 & B8 & B7 & B6 & B5 & B4 & B3 & B2 & B1 & B0);
    SRIA_ipd <= (SRIA17 & SRIA16 & SRIA15 & SRIA14 & SRIA13 & SRIA12 & SRIA11 & SRIA10 & SRIA9 & SRIA8 & SRIA7 & SRIA6 & SRIA5 & SRIA4 & SRIA3 & SRIA2 & SRIA1 & SRIA0);
    SRIB_ipd <= (SRIB17 & SRIB16 & SRIB15 & SRIB14 & SRIB13 & SRIB12 & SRIB11 & SRIB10 & SRIB9 & SRIB8 & SRIB7 & SRIB6 & SRIB5 & SRIB4 & SRIB3 & SRIB2 & SRIB1 & SRIB0); 
    SIGNEDAB_ipd <= SIGNEDAB;
    CE0_ipd <= CE0;
    CE1_ipd <= CE1;
    CE2_ipd <= CE2;
    CE3_ipd <= CE3;
    CLK0_ipd <= CLK0;
    CLK1_ipd <= CLK1;
    CLK2_ipd <= CLK2;
    CLK3_ipd <= CLK3;
    RST0_ipd <= RST0;
    RST1_ipd <= RST1;
    RST2_ipd <= RST2;
    RST3_ipd <= RST3;

    SROA0 <= SROA_reg(0);
    SROA1 <= SROA_reg(1);
    SROA2 <= SROA_reg(2);
    SROA3 <= SROA_reg(3);
    SROA4 <= SROA_reg(4);
    SROA5 <= SROA_reg(5);
    SROA6 <= SROA_reg(6);
    SROA7 <= SROA_reg(7);
    SROA8 <= SROA_reg(8);
    SROA9 <= SROA_reg(9);
    SROA10 <= SROA_reg(10);
    SROA11 <= SROA_reg(11);
    SROA12 <= SROA_reg(12);
    SROA13 <= SROA_reg(13);
    SROA14 <= SROA_reg(14);
    SROA15 <= SROA_reg(15);
    SROA16 <= SROA_reg(16);
    SROA17 <= SROA_reg(17);

    SROB0 <= SROB_reg(0);
    SROB1 <= SROB_reg(1);
    SROB2 <= SROB_reg(2);
    SROB3 <= SROB_reg(3);
    SROB4 <= SROB_reg(4);
    SROB5 <= SROB_reg(5);
    SROB6 <= SROB_reg(6);
    SROB7 <= SROB_reg(7);
    SROB8 <= SROB_reg(8);
    SROB9 <= SROB_reg(9);
    SROB10 <= SROB_reg(10);
    SROB11 <= SROB_reg(11);
    SROB12 <= SROB_reg(12);
    SROB13 <= SROB_reg(13);
    SROB14 <= SROB_reg(14);
    SROB15 <= SROB_reg(15);
    SROB16 <= SROB_reg(16);
    SROB17 <= SROB_reg(17);

    P0 <= P_ipd(0);
    P1 <= P_ipd(1);
    P2 <= P_ipd(2);
    P3 <= P_ipd(3);
    P4 <= P_ipd(4);
    P5 <= P_ipd(5);
    P6 <= P_ipd(6);
    P7 <= P_ipd(7);
    P8 <= P_ipd(8);
    P9 <= P_ipd(9);
    P10 <= P_ipd(10);
    P11 <= P_ipd(11);
    P12 <= P_ipd(12);
    P13 <= P_ipd(13);
    P14 <= P_ipd(14);
    P15 <= P_ipd(15);
    P16 <= P_ipd(16);
    P17 <= P_ipd(17);
    P18 <= P_ipd(18);
    P19 <= P_ipd(19);
    P20 <= P_ipd(20);
    P21 <= P_ipd(21);
    P22 <= P_ipd(22);
    P23 <= P_ipd(23);
    P24 <= P_ipd(24);
    P25 <= P_ipd(25);
    P26 <= P_ipd(26);
    P27 <= P_ipd(27);
    P28 <= P_ipd(28);
    P29 <= P_ipd(29);
    P30 <= P_ipd(30);
    P31 <= P_ipd(31);
    P32 <= P_ipd(32);
    P33 <= P_ipd(33);
    P34 <= P_ipd(34);
    P35 <= P_ipd(35);


  Input_A_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_INPUTA_CLK = "CLK0") then
       input_a_clk <= CLK0_ipd;
     elsif (REG_INPUTA_CLK = "CLK1") then
       input_a_clk <= CLK1_ipd;
     elsif (REG_INPUTA_CLK = "CLK2") then
       input_a_clk <= CLK2_ipd;
     elsif (REG_INPUTA_CLK = "CLK3") then
       input_a_clk <= CLK3_ipd;
     end if;
  end process;

  Input_A_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_INPUTA_CE = "CE0") then
       input_a_ce <= CE0_ipd;
     elsif (REG_INPUTA_CE = "CE1") then
       input_a_ce <= CE1_ipd;
     elsif (REG_INPUTA_CE = "CE2") then
       input_a_ce <= CE2_ipd;
     elsif (REG_INPUTA_CE = "CE3") then
       input_a_ce <= CE3_ipd;
     end if;
  end process;

  Input_A_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_INPUTA_RST = "RST0") then
       input_a_rst <= RST0_ipd;
     elsif (REG_INPUTA_RST = "RST1") then
       input_a_rst <= RST1_ipd;
     elsif (REG_INPUTA_RST = "RST2") then
       input_a_rst <= RST2_ipd;
     elsif (REG_INPUTA_RST = "RST3") then
       input_a_rst <= RST3_ipd;
     end if;
  end process;
      
  Register_A_Input : process(input_a_clk, input_a_rst_ogsr, input_a_ce, A_ipd, a_gen)
  begin
     if (input_a_rst_ogsr = '1') then
       A_reg <= (others => '0');
       SROA_reg <= (others => '0');
     elsif (rising_edge(input_a_clk)) then
       if (input_a_ce = '1') then
         A_reg <= A_ipd;
         SROA_reg <= a_gen;
       end if;
     end if;
  end process;

  Select_A_OR_A_reg : process (A_ipd, A_reg)
  begin
     if (REG_INPUTA_CLK = "NONE") then
       A_p <= A_ipd;
     else
       A_p <= A_reg;
     end if;
  end process;

  Select_A_p_OR_SRIA_ipd : process(A_p, SRIA_ipd)
  begin
     if (SHIFT_IN_A = "TRUE") then
       a_gen <= SRIA_ipd;
     elsif (SHIFT_IN_A = "FALSE") then 
       a_gen <= A_p;
     end if;
  end process;    

  Input_B_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_INPUTB_CLK = "CLK0") then
       input_b_clk <= CLK0_ipd;
     elsif (REG_INPUTB_CLK = "CLK1") then
       input_b_clk <= CLK1_ipd;
     elsif (REG_INPUTB_CLK = "CLK2") then
       input_b_clk <= CLK2_ipd;
     elsif (REG_INPUTB_CLK = "CLK3") then
       input_b_clk <= CLK3_ipd;
     end if;
  end process;

  Input_B_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_INPUTB_CE = "CE0") then
       input_b_ce <= CE0_ipd;
     elsif (REG_INPUTB_CE = "CE1") then
       input_b_ce <= CE1_ipd;
     elsif (REG_INPUTB_CE = "CE2") then
       input_b_ce <= CE2_ipd;
     elsif (REG_INPUTB_CE = "CE3") then
       input_b_ce <= CE3_ipd;
     end if;
  end process;

  Input_B_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_INPUTB_RST = "RST0") then
       input_b_rst <= RST0_ipd;
     elsif (REG_INPUTB_RST = "RST1") then
       input_b_rst <= RST1_ipd;
     elsif (REG_INPUTB_RST = "RST2") then
       input_b_rst <= RST2_ipd;
     elsif (REG_INPUTB_RST = "RST3") then
       input_b_rst <= RST3_ipd;
     end if;
  end process;

  Register_B_Input : process(input_b_clk, input_b_rst_ogsr, input_b_ce, B_ipd, b_gen)
  begin
     if (input_b_rst_ogsr = '1') then
       B_reg <= (others => '0');
       SROB_reg <= (others => '0');
     elsif (rising_edge(input_b_clk)) then
       if (input_b_ce = '1') then
         B_reg <= B_ipd;
         SROB_reg <= b_gen;
       end if;
     end if;
  end process;

  Select_B_OR_B_reg : process (B_ipd, B_reg)
  begin
     if (REG_INPUTB_CLK = "NONE") then
       B_p <= B_ipd;
     else
       B_p <= B_reg;
     end if;
  end process;    
    
  Select_B_p_OR_SRIB_ipd : process(B_p, SRIB_ipd)
  begin
     if (SHIFT_IN_B = "TRUE") then
       b_gen <= SRIB_ipd;
     elsif (SHIFT_IN_B = "FALSE") then 
       b_gen <= B_p;
     end if;
  end process;   


  SIGNEDAB_0_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_SIGNEDAB_0_CLK = "CLK0") then
       signedab_0_clk <= CLK0_ipd;
     elsif (REG_SIGNEDAB_0_CLK = "CLK1") then
       signedab_0_clk <= CLK1_ipd;
     elsif (REG_SIGNEDAB_0_CLK = "CLK2") then
       signedab_0_clk <= CLK2_ipd;
     elsif (REG_SIGNEDAB_0_CLK = "CLK3") then
       signedab_0_clk <= CLK3_ipd;
     end if;
  end process;

  SIGNEDAB_0_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_SIGNEDAB_0_CE = "CE0") then
       signedab_0_ce <= CE0_ipd;
     elsif (REG_SIGNEDAB_0_CE = "CE1") then
       signedab_0_ce <= CE1_ipd;
     elsif (REG_SIGNEDAB_0_CE = "CE2") then
       signedab_0_ce <= CE2_ipd;
     elsif (REG_SIGNEDAB_0_CE = "CE3") then
       signedab_0_ce <= CE3_ipd;
     end if;
  end process;

  SIGNEDAB_0_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_SIGNEDAB_0_RST = "RST0") then
       signedab_0_rst <= RST0_ipd;
     elsif (REG_SIGNEDAB_0_RST = "RST1") then
       signedab_0_rst <= RST1_ipd;
     elsif (REG_SIGNEDAB_0_RST = "RST2") then
       signedab_0_rst <= RST2_ipd;
     elsif (REG_SIGNEDAB_0_RST = "RST3") then
       signedab_0_rst <= RST3_ipd;
     end if;
  end process;

  Register_0_SIGNEDAB : process(signedab_0_clk, signedab_0_rst_ogsr, signedab_0_ce, SIGNEDAB_ipd)
  begin
     if (signedab_0_rst_ogsr = '1') then
       signedab_0_reg <= '0';
     elsif (rising_edge(signedab_0_clk)) then
       if (signedab_0_ce = '1') then
         signedab_0_reg <= SIGNEDAB_ipd;
       end if;
     end if;
  end process;

  Select_SIGNEDAB_ipd_OR_SIGNEDAB_0_reg : process (SIGNEDAB_ipd, signedab_0_reg)
  begin
     if (REG_SIGNEDAB_0_CLK = "NONE") then
       signedab_p1 <= SIGNEDAB_ipd;
     else
       signedab_p1 <= signedab_0_reg;
     end if;
  end process; 

  SIGNEDAB_1_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_SIGNEDAB_1_CLK = "CLK0") then
       signedab_1_clk <= CLK0_ipd;
     elsif (REG_SIGNEDAB_1_CLK = "CLK1") then
       signedab_1_clk <= CLK1_ipd;
     elsif (REG_SIGNEDAB_1_CLK = "CLK2") then
       signedab_1_clk <= CLK2_ipd;
     elsif (REG_SIGNEDAB_1_CLK = "CLK3") then
       signedab_1_clk <= CLK3_ipd;
     end if;
  end process;

  SIGNEDAB_1_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_SIGNEDAB_1_CE = "CE0") then
       signedab_1_ce <= CE0_ipd;
     elsif (REG_SIGNEDAB_1_CE = "CE1") then
       signedab_1_ce <= CE1_ipd;
     elsif (REG_SIGNEDAB_1_CE = "CE2") then
       signedab_1_ce <= CE2_ipd;
     elsif (REG_SIGNEDAB_1_CE = "CE3") then
       signedab_1_ce <= CE3_ipd;
     end if;
  end process;

  SIGNEDAB_1_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_SIGNEDAB_1_RST = "RST0") then
       signedab_1_rst <= RST0_ipd;
     elsif (REG_SIGNEDAB_1_RST = "RST1") then
       signedab_1_rst <= RST1_ipd;
     elsif (REG_SIGNEDAB_0_RST = "RST2") then
       signedab_1_rst <= RST2_ipd;
     elsif (REG_SIGNEDAB_1_RST = "RST3") then
       signedab_1_rst <= RST3_ipd;
     end if;
  end process;

  Register_1_SIGNEDAB : process(signedab_1_clk, signedab_1_rst_ogsr, signedab_1_ce, signedab_p1)
  begin
     if (signedab_0_rst_ogsr = '1') then
       signedab_1_reg <= '0';
     elsif (rising_edge(signedab_1_clk)) then
       if (signedab_1_ce = '1') then
         signedab_1_reg <= signedab_p1;
       end if;
     end if;
  end process;

  Select_SIGNEDAB_ipd_OR_SIGNEDAB_1_reg : process (signedab_p1, signedab_1_reg)
  begin
     if (REG_SIGNEDAB_1_CLK = "NONE") then
       signedab_p2 <= signedab_p1;
     else
       signedab_p2 <= signedab_1_reg;
     end if;
  end process;      

  VITALMultBehavior : process(A_gen, B_gen)

    variable O_zd, OT1_zd, OT2_zd : std_logic_vector( 35 downto 0);
    variable IA,IBL,IBU  : integer ;
    variable sign : std_logic := '0';
    variable A_i : std_logic_vector(17 downto 0);
    variable B_i : std_logic_vector(17 downto 0);

  begin -- process

    if ((A_gen = "000000000000000000") or (B_gen = "000000000000000000")) then
            O_zd := (others => '0');
    elsif (VECX(A_gen) or VECX(B_gen) ) then
            O_zd := (others => 'X');
    else
      if (signedab_p2 = '1') then
         if (A_gen(17) = '1' ) then
           A_i :=  TSCOMP(A_gen);
         else 
           A_i := A_gen;
         end if;

         if (B_gen(17)  = '1') then
           B_i := TSCOMP(B_gen);
         else
           B_i := B_gen;
         end if;

         IA  := VEC2INT(A_i);
         IBU := VEC2INT(B_i (17 downto 9));
         IBL := VEC2INT(B_i (8 downto 0));

         OT1_zd := INT2VEC((IA * IBU), 36);
         for idex in 0 to 8 loop
             OT1_zd(35 downto 0) := OT1_zd(34 downto 0) & '0';
         end loop;
 
         OT2_zd := INT2VEC((IA * IBL), 36);
         O_zd   := ADDVECT(OT1_zd,OT2_zd);

         sign := A_gen(17) xor B_gen(17);
         if (sign = '1' ) then
              O_zd := TSCOMP(O_zd);
         end if;
      else
         A_i := A_gen;
         B_i := B_gen;

         IA  := VEC2INT(A_i);
         IBU := VEC2INT(B_i (17 downto 9));
         IBL := VEC2INT(B_i (8 downto 0));

         OT1_zd := INT2VEC((IA * IBU), 36);
         for idex in 0 to 8 loop
             OT1_zd(35 downto 0) := OT1_zd(34 downto 0) & '0';
         end loop;
 
         OT2_zd := INT2VEC((IA * IBL), 36);
         O_zd   := ADDVECT(OT1_zd,OT2_zd);
      end if;

    end if;

    p_i <= O_ZD; 

  end process;


  PipeLine_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_PIPELINE_CLK = "CLK0") then
       pipeline_clk <= CLK0_ipd;
     elsif (REG_PIPELINE_CLK = "CLK1") then
       pipeline_clk <= CLK1_ipd;
     elsif (REG_PIPELINE_CLK = "CLK2") then
       pipeline_clk <= CLK2_ipd;
     elsif (REG_PIPELINE_CLK = "CLK3") then
       pipeline_clk <= CLK3_ipd;
     end if;
  end process;

  PipeLine_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_PIPELINE_CE = "CE0") then
       pipeline_ce <= CE0_ipd;
     elsif (REG_PIPELINE_CE = "CE1") then
       pipeline_ce <= CE1_ipd;
     elsif (REG_PIPELINE_CE = "CE2") then
       pipeline_ce <= CE2_ipd;
     elsif (REG_PIPELINE_CE = "CE3") then
       pipeline_ce <= CE3_ipd;
     end if;
  end process;

  PipeLine_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_PIPELINE_RST = "RST0") then
       pipeline_rst <= RST0_ipd;
     elsif (REG_PIPELINE_RST = "RST1") then
       pipeline_rst <= RST1_ipd;
     elsif (REG_PIPELINE_RST = "RST2") then
       pipeline_rst <= RST2_ipd;
     elsif (REG_PIPELINE_RST = "RST3") then
       pipeline_rst <= RST3_ipd;
     end if;
  end process;

  Pipeline_p_i : process(pipeline_clk, pipeline_rst_ogsr, pipeline_ce, p_i)
  begin
     if (pipeline_rst_ogsr = '1') then
       p_o <= (others => '0');
     elsif (rising_edge(pipeline_clk)) then
       if (pipeline_ce = '1') then
         p_o <= p_i;
       end if;
     end if;
  end process;

  Select_NOPIPELINE_OR_PIPELINE : process (p_i, p_o)
  begin
     if (REG_PIPELINE_CLK = "NONE") then
       p_ps <= p_i;
     else
       p_ps <= p_o;
     end if;
  end process;

  Output_Clock  : process(CLK0_ipd, CLK1_ipd, CLK2_ipd, CLK3_ipd)
  begin
     if (REG_OUTPUT_CLK = "CLK0") then
       output_clk <= CLK0_ipd;
     elsif (REG_OUTPUT_CLK = "CLK1") then
       output_clk <= CLK1_ipd;
     elsif (REG_OUTPUT_CLK = "CLK2") then
       output_clk <= CLK2_ipd;
     elsif (REG_OUTPUT_CLK = "CLK3") then
       output_clk <= CLK3_ipd;
     end if;
  end process;

  Output_ClockEnable  : process(CE0_ipd, CE1_ipd, CE2_ipd, CE3_ipd)
  begin
     if (REG_OUTPUT_CE = "CE0") then
       output_ce <= CE0_ipd;
     elsif (REG_OUTPUT_CE = "CE1") then
       output_ce <= CE1_ipd;
     elsif (REG_OUTPUT_CE = "CE2") then
       output_ce <= CE2_ipd;
     elsif (REG_OUTPUT_CE = "CE3") then
       output_ce <= CE3_ipd;
     end if;
  end process;

  Output_Reset  : process(RST0_ipd, RST1_ipd, RST2_ipd, RST3_ipd)
  begin
     if (REG_OUTPUT_RST = "RST0") then
       output_rst <= RST0_ipd;
     elsif (REG_OUTPUT_RST = "RST1") then
       output_rst <= RST1_ipd;
     elsif (REG_OUTPUT_RST = "RST2") then
       output_rst <= RST2_ipd;
     elsif (REG_OUTPUT_RST = "RST3") then
       output_rst <= RST3_ipd;
     end if;
  end process;

  Output_Register : process(output_clk, output_rst_ogsr, output_ce, p_ps)
  begin
     if (output_rst_ogsr = '1') then
       p_o1 <= (others => '0');
     elsif (rising_edge(output_clk)) then
       if (output_ce = '1') then
         p_o1 <= p_ps;
       end if;
     end if;
  end process;

  Select_OUTREG_OR_NOREG : process (p_ps, p_o1)
  begin
     if (REG_OUTPUT_CLK = "NONE") then
       P_ipd <= p_ps;
     else
       P_ipd <= p_o1;
     end if;
  end process;

end V;
