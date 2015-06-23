--Propery of Tecphos Inc.  See License.txt for license details
--Latest version of all project files available at
--http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

------------------------------------------------------------
--**********************************************************
--!!!!!!!!!!!!!!!!!!    EDIT THIS FILE     !!!!!!!!!!!!!!!!!
--Save a copy of this file in a project specific directory.
--Each project may have a different WrimmPackage.vhd file.
--Hopefully wrimm.vhd will not require modification for each
--project.
-->>>>>>>>>>>>>>>>>>>>>>>Start of Customization Example>>>>>>>>>>>>>>>>>>>>>>>>>
--  Edit or at least verify the data in all the sections of this file
--  surrounded by the indicator lines shown above and below this text.
--<<<<<<<<<<<<<<<<<<<<<<<End of Customization Ecample<<<<<<<<<<<<<<<<<<<<<<<<<<<
--  Hopefully the code ouside those marked sections
--  will not require modification.
--**********************************************************
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package WrimmPackage is
-->>>>>>>>>>>>>>>>>>>>>>>Start of Wishbone Bus Parameters >>>>>>>>>>>>>>>>>>>>>>
  constant WbAddrBits : integer := 4;
  constant WbDataBits : integer := 8;
--<<<<<<<<<<<<<<<<<<<<<<<End of Wishbone Bus Parameters <<<<<<<<<<<<<<<<<<<<<<<<

  subtype WbAddrType is std_logic_vector(0 to WbAddrBits-1);
  subtype WbDataType is std_logic_vector(0 to WbDataBits-1);

  type WbMasterOutType is record
    Strobe : std_logic;                 --Required
    WrEn   : std_logic;                 --Required
    Addr   : WbAddrType;                --Required
    Data   : WbDataType;
    --DataTag       : std_logic_vector(0 to 1);   --Write,Set,Clear,Toggle
    Cyc    : std_logic;                 --Required
    --CycType       : std_logic_vector(0 to 2);   --For Burst Cycles
  end record WbMasterOutType;

  type WbSlaveOutType is record
    Ack  : std_logic;                   --Required
    Err  : std_logic;
    Rty  : std_logic;
    Data : WbDataType;
  end record WbSlaveOutType;

--==========================================================
------------------------------------------------------------
--  Master Interfaces: provides interfaces for 1-n Masters
------------------------------------------------------------
  type WbMasterType is (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Wishbone Master List >>>>>>>>>>>>>>>>>>>>>>>>>
    Q,
    P);
--<<<<<<<<<<<<<<<<<<<<<<<End of Wishbone Master List <<<<<<<<<<<<<<<<<<<<<<<<<<<

  type WbMasterOutArray is array (WbMasterType) of WbMasterOutType;
  type WbSlaveOutArray is array (WbMasterType) of WbSlaveOutType;

  type WbMasterGrantType is array (WbMasterType'left to WbMasterType'right) of std_logic;
--==========================================================
------------------------------------------------------------
--  Status Registers: Report results from other modules
------------------------------------------------------------
  type StatusFieldParams is record
    BitWidth : integer;
    MSBLoc   : integer;
    Address  : WbAddrType;
  end record StatusFieldParams;

  type StatusFieldType is (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Status Field List >>>>>>>>>>>>>>>>>>>>>>>>>>>>
    StatusA,
    StatusB,
    StatusC);
--<<<<<<<<<<<<<<<<<<<<<<<End of Status Field List <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  type StatusArrayType is array (StatusFieldType'left to StatusFieldType'right) of WbDataType;
  type StatusArrayBitType is array (StatusFieldType'left to StatusFieldType'right) of std_logic;
  type StatusFieldDefType is array (StatusFieldType'left to StatusFieldType'right) of StatusFieldParams;

  constant StatusParams : StatusFieldDefType := (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Status Field Parameters >>>>>>>>>>>>>>>>>>>>>>
    StatusA => (BitWidth => 8, MSBLoc => 0, Address => x"0"),
    StatusB => (BitWidth => 8, MSBLoc => 0, Address => x"1"),
    StatusC => (BitWidth => 8, MSBLoc => 0, Address => x"2"));
--<<<<<<<<<<<<<<<<<<<<<<<End of Status Field Parameters <<<<<<<<<<<<<<<<<<<<<<<<
--==========================================================
------------------------------------------------------------
--  Setting Registers: Provide config bits to other modules
------------------------------------------------------------
  type SettingFieldParams is record
    BitWidth : integer;
    MSBLoc   : integer;
    Address  : WbAddrType;
    Default  : WbDataType;
  end record SettingFieldParams;

  type SettingFieldType is (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Setting Field List >>>>>>>>>>>>>>>>>>>>>>>>>>>
    SettingX,
    SettingY,
    SettingZ);
--<<<<<<<<<<<<<<<<<<<<<<<End of Setting Field List <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  type SettingArrayType is array (SettingFieldType'left to SettingFieldType'right) of WbDataType;
  type SettingArrayBitType is array (SettingFieldType'left to SettingFieldType'right) of std_logic;
  type SettingFieldDefType is array (SettingFieldType'left to SettingFieldType'right) of SettingFieldParams;

  constant SettingParams : SettingFieldDefType := (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Setting Field Parameters >>>>>>>>>>>>>>>>>>>>>
    SettingX => (BitWidth => 8, MSBLoc => 0, Address => x"6", Default => x"05"),
    SettingY => (BitWidth => 8, MSBLoc => 0, Address => x"7", Default => x"3C"),
    SettingZ => (BitWidth => 8, MSBLoc => 0, Address => x"8", Default => x"AA"));
--<<<<<<<<<<<<<<<<<<<<<<<End of Setting Field Parameters<<<<<<<<<<<<<<<<<<<<<<<<
--==========================================================
------------------------------------------------------------
--  Trigger Registers, Launch other processes, cleared by those processes
------------------------------------------------------------
  type TriggerFieldParams is record
    BitLoc  : integer;
    Address : WbAddrType;
  end record TriggerFieldParams;

  type TriggerFieldType is (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Trigger List >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    TriggerR,
    TriggerS,
    TriggerT);
--<<<<<<<<<<<<<<<<<<<<<<<End of Trigger List <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  type TriggerArrayType is array (TriggerFieldType'left to TriggerFieldType'right) of std_logic;
  type TriggerFieldDefType is array (TriggerFieldType'left to TriggerFieldType'right) of TriggerFieldParams;

  constant TriggerParams : TriggerFieldDefType := (
-->>>>>>>>>>>>>>>>>>>>>>>Start of Trigger Parameters >>>>>>>>>>>>>>>>>>>>>>>>>>>
    TriggerR => (BitLoc => 7, Address => x"A"),
    TriggerS => (BitLoc => 7, Address => x"B"),
    TriggerT => (BitLoc => 7, Address => x"C"));
--<<<<<<<<<<<<<<<<<<<<<<<End of Trigger Parameters <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

end package WrimmPackage;

--package body WishBonePackage is
--
-- No package functions (yet)
--
--end package body WishBonePackage;
