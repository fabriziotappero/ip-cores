library ieee;
use ieee.std_logic_1164.all;
use ieee.vital_timing.ALL;
USE ieee.vital_primitives.ALL;

library fmf;
use fmf.gen_utils.all;
use fmf.conversions.all;

package flash is

  component s25fl064a
    generic (
      tipd_SCK            : VitalDelayType01 := VitalZeroDelay01;
      tipd_SI             : VitalDelayType01 := VitalZeroDelay01;
      tipd_CSNeg          : VitalDelayType01 := VitalZeroDelay01;
      tipd_HOLDNeg        : VitalDelayType01 := VitalZeroDelay01;
      tipd_WNeg           : VitalDelayType01 := VitalZeroDelay01;
      tpd_SCK_SO          : VitalDelayType01Z := UnitDelay01Z;
      tpd_CSNeg_SO        : VitalDelayType01Z := UnitDelay01Z;
      tpd_HOLDNeg_SO      : VitalDelayType01Z := UnitDelay01Z;
      tsetup_SI_SCK       : VitalDelayType := UnitDelay;
      tsetup_CSNeg_SCK    : VitalDelayType := UnitDelay;
      tsetup_HOLDNeg_SCK  : VitalDelayType := UnitDelay;
      tsetup_WNeg_CSNeg   : VitalDelayType := UnitDelay;
      thold_SI_SCK        : VitalDelayType := UnitDelay;
      thold_CSNeg_SCK     : VitalDelayType := UnitDelay;
      thold_HOLDNeg_SCK   : VitalDelayType := UnitDelay;
      thold_WNeg_CSNeg    : VitalDelayType := UnitDelay;
      tpw_SCK_posedge     : VitalDelayType := UnitDelay;
      tpw_SCK_negedge     : VitalDelayType := UnitDelay;
      tpw_CSNeg_posedge   : VitalDelayType := UnitDelay;
      tperiod_SCK_rd      : VitalDelayType := UnitDelay;
      tperiod_SCK_fast_rd : VitalDelayType := UnitDelay;
      tdevice_PP          : VitalDelayType    := 3 ms;
      tdevice_SE          : VitalDelayType    := 3 sec;
      tdevice_BE          : VitalDelayType    := 384 sec;
      tdevice_WR          : VitalDelayType    := 60 ms;
      tdevice_DP          : VitalDelayType    := 3 us;
      tdevice_RES         : VitalDelayType    := 30 us;
      tdevice_PU          : VitalDelayType    := 10 ms;
      InstancePath        : STRING    := DefaultInstancePath;
      TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
      MsgOn               : BOOLEAN   := DefaultMsgOn;
      XOn                 : BOOLEAN   := DefaultXon;
      mem_file_name       : STRING    := "s25fl064a.mem";
      UserPreload         : BOOLEAN   := FALSE;
      LongTimming         : BOOLEAN   := TRUE;
      TimingModel         : STRING    := DefaultTimingModel
      );
    port (
      SCK             : IN    std_ulogic := 'U';
      SI              : IN    std_ulogic := 'U';
      CSNeg           : IN    std_ulogic := 'U';
      HOLDNeg         : IN    std_ulogic := 'U';
      WNeg            : IN    std_ulogic := 'U';
      SO              : OUT   std_ulogic := 'U'
    );
  end component;

  component m25p80
    generic (
      tipd_C            : VitalDelayType01 := VitalZeroDelay01;
      tipd_D            : VitalDelayType01 := VitalZeroDelay01;
      tipd_SNeg         : VitalDelayType01 := VitalZeroDelay01;
      tipd_HOLDNeg      : VitalDelayType01 := VitalZeroDelay01;
      tipd_WNeg         : VitalDelayType01 := VitalZeroDelay01;
      tpd_C_Q           : VitalDelayType01  := UnitDelay01;
      tpd_SNeg_Q        : VitalDelayType01Z := UnitDelay01Z;
      tpd_HOLDNeg_Q     : VitalDelayType01Z := UnitDelay01Z;
      tsetup_D_C        : VitalDelayType := UnitDelay;
      tsetup_SNeg_C     : VitalDelayType := UnitDelay;
      tsetup_HOLDNeg_C  : VitalDelayType := UnitDelay;
      tsetup_C_HOLDNeg  : VitalDelayType := UnitDelay;
      tsetup_WNeg_SNeg  : VitalDelayType := UnitDelay;
      thold_D_C         : VitalDelayType := UnitDelay;
      thold_SNeg_C      : VitalDelayType := UnitDelay;
      thold_HOLDNeg_C   : VitalDelayType := UnitDelay;
      thold_C_HOLDNeg   : VitalDelayType := UnitDelay;
      thold_WNeg_SNeg   : VitalDelayType := UnitDelay;
      tpw_C_posedge     : VitalDelayType := UnitDelay;
      tpw_C_negedge     : VitalDelayType := UnitDelay;
      tpw_SNeg_posedge  : VitalDelayType := UnitDelay;
      tperiod_C_rd      : VitalDelayType := UnitDelay;
      tperiod_C_fast_rd : VitalDelayType := UnitDelay;
      tdevice_PP        : VitalDelayType    := 5 ms;
      tdevice_SE        : VitalDelayType    := 3 sec;
      tdevice_BE        : VitalDelayType    := 20 sec;
      tdevice_WR        : VitalDelayType    := 15 ms;
      tdevice_DP        : VitalDelayType    := 3 us;
      tdevice_RES1      : VitalDelayType    := 3 us;
      tdevice_RES2      : VitalDelayType    := 1.8 us;
      tdevice_VSL       : VitalDelayType    := 10 us;
      tdevice_PUW       : VitalDelayType    := 10 ms;
      InstancePath      : STRING    := DefaultInstancePath;
      TimingChecksOn    : BOOLEAN   := DefaultTimingChecks;
      MsgOn             : BOOLEAN   := DefaultMsgOn;
      XOn               : BOOLEAN   := DefaultXon;
      mem_file_name     : STRING    := "m25p80.mem";
      UserPreload       : BOOLEAN   := FALSE;
      DebugInfo         : BOOLEAN   := FALSE;
      LongTimming       : BOOLEAN   := TRUE;
      TimingModel       : STRING    := DefaultTimingModel
    );
    port (
      C             : IN    std_ulogic := 'U';
      D             : IN    std_ulogic := 'U';
      SNeg          : IN    std_ulogic := 'U';
      HOLDNeg       : IN    std_ulogic := 'U';
      WNeg          : IN    std_ulogic := 'U';
      Q             : OUT   std_ulogic := 'U'
    );
  end component;
  
end flash;
