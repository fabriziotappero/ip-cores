--Propery of Tecphos Inc.  See License.txt for license details
--Latest version of all project files available at http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use work.WrimmPackage.all;

entity Wrimm_Top is
  port (
    WishboneClock       : in  std_logic;
    WishboneReset       : out std_logic;

    MasterPStrobe       : in  std_logic;
    MasterPWrEn         : in  std_logic;
    MasterPCyc          : in  std_logic;
    MasterPAddr         : in  WbAddrType;
    MasterPDataToSlave  : in  WbDataType;
    MasterPAck          : out std_logic;
    MasterPErr          : out std_logic;
    MasterPRty          : out std_logic;
    MasterPDataFrSlave  : out WbDataType;

    MasterQStrobe       : in  std_logic;
    MasterQWrEn         : in  std_logic;
    MasterQCyc          : in  std_logic;
    MasterQAddr         : in  WbAddrType;
    MasterQDataToSlave  : in  WbDataType;
    MasterQAck          : out std_logic;
    MasterQErr          : out std_logic;
    MasterQRty          : out std_logic;
    MasterQDataFrSlave  : out WbDataType;

    StatusRegA          : in  std_logic_vector(0 to 7);
    StatusRegB          : in  std_logic_vector(0 to 7);
    StatusRegC          : in  std_logic_vector(0 to 7);

    SettingRegX         : out std_logic_vector(0 to 7);
    SettingRstX         : in  std_logic;
    SettingRegY         : out std_logic_vector(0 to 7);
    SettingRstY         : in  std_logic;
    SettingRegZ         : out std_logic_vector(0 to 7);
    SettingRstZ         : in  std_logic;

    TriggerRegR         : out std_logic;
    TriggerClrR         : in  std_logic;
    TriggerRegS         : out std_logic;
    TriggerClrS         : in  std_logic;
    TriggerRegT         : out std_logic;
    TriggerClrT         : in  std_logic;

    rstZ                : in  std_logic);  --Global asyncronous reset for initialization
end entity Wrimm_Top;

architecture structure of Wrimm_Top is

  component Wrimm is
    port (
      WbClk             : in  std_logic;
      WbRst             : out std_logic;
      WbMasterIn        : in  WbMasterOutArray; --Signals from Masters
      WbMasterOut       : out WbSlaveOutArray;  --Signals to Masters
    --  WbSlaveIn         : out WbMasterOutArray;
    --  WbSlaveOut        : in  WbSlaveOutArray;
      StatusRegs        : in  StatusArrayType;
      SettingRegs       : out SettingArrayType;
      SettingRsts       : in  SettingArrayBitType;
      Triggers          : out TriggerArrayType;
      TriggerClr        : in  TriggerArrayType;
      rstZ              : in  std_logic);                         --Asynchronous reset
  end component Wrimm;

  signal masterQOut           : WbSlaveOutType;
  signal masterQIn            : WbMasterOutType;

begin
    MasterQAck          <= masterQOut.ack;
    MasterQErr          <= masterQOut.err;
    MasterQRty          <= masterQOut.rty;
    MasterQDataFrSlave  <= masterQOut.data;

    masterQIn.strobe    <= MasterQStrobe;
    masterQIn.wren      <= MasterQWrEn;
    masterQIn.cyc       <= MasterQCyc;
    masterQIn.addr      <= MasterQAddr;
    masterQIn.data      <= MasterQDataToSlave;

  instWrimm: Wrimm
    --generic map(
    --  MasterParams      => ,
    --  SlaveParams       => ,
    --  StatusParams      => StatusParams,
    --  SettingParams     => SettingParams,
    --  TriggerParams     => TriggerParams)
    port map(
      WbClk                 => WishboneClock,
      WbRst                 => WishboneReset,
      WbMasterIn(P).strobe  => MasterPStrobe,
      WbMasterIn(P).wren    => MasterPWrEn,
      WbMasterIn(P).cyc     => MasterPCyc,
      WbMasterIn(P).addr    => MasterPAddr,
      WbMasterIn(P).data    => MasterPDataToSlave,
      WbMasterIn(Q)         => masterQIn,
      WbMasterOut(P).ack    => MasterPAck,
      WbMasterOut(P).err    => MasterPErr,
      WbMasterOut(P).rty    => MasterPRty,
      WbMasterOut(P).data   => MasterPDataFrSlave,
      WbMasterOut(Q)        => masterQOut,
      --WbSlaveIn         => ,
      --WbSlaveOut        => ,
      StatusRegs(StatusA)   => StatusRegA,
      StatusRegs(StatusB)   => StatusRegB,
      StatusRegs(StatusC)   => StatusRegC,
      SettingRegs(SettingX) => SettingRegX,
      SettingRegs(SettingY) => SettingRegY,
      SettingRegs(SettingZ) => SettingRegZ,
      SettingRsts(SettingX) => SettingRstX,
      SettingRsts(SettingY) => SettingRstY,
      SettingRsts(SettingZ) => SettingRstZ,
      Triggers(TriggerR)    => TriggerRegR,
      Triggers(TriggerS)    => TriggerRegS,
      Triggers(TriggerT)    => TriggerRegT,
      TriggerClr(TriggerR)  => TriggerClrR,
      TriggerClr(TriggerS)  => TriggerClrS,
      TriggerClr(TriggerT)  => TriggerClrT,
      rstZ                  => rstZ);             --Asynchronous reset

end architecture structure;