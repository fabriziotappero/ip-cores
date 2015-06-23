--Propery of Tecphos Inc.  See WrimmLicense.txt for license details
--Latest version of all Wrimm project files available at http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use work.WrimmPackage.all;

entity Wrimm is
  port (
    WbClk             : in  std_logic;
    WbRst             : out std_logic;

    WbMasterIn        : in  WbMasterOutArray; --Signals from Masters
    WbMasterOut       : out WbSlaveOutArray;  --Signals to Masters

    --WbSlaveIn         : out WbMasterOutArray;
    --WbSlaveOut        : in  WbSlaveOutArray;

    StatusRegs        : in  StatusArrayType;

    SettingRegs       : out SettingArrayType;
    SettingRsts       : in  SettingArrayBitType;

    Triggers          : out TriggerArrayType;
    TriggerClr        : in  TriggerArrayType;

    rstZ              : in  std_logic);                         --Asynchronous reset
end entity Wrimm;

architecture behavior of Wrimm is
  signal  wbStrobe                : std_logic;    --Internal Wishbone signals
  signal  validAddress            : std_logic;
  signal  wbAddr                  : WbAddrType;
  signal  wbSData,wbMData         : WbDataType;
  signal  wbWrEn,wbCyc            : std_logic;
  signal  wbAck,wbRty,wbErr       : std_logic;
  --signal  wbMDataTag              : std_logic_vector(0 to 1);
  --signal  wbCycType               : std_logic_vector(0 to 2);

  signal  iSettingRegs            : SettingArrayType;
  signal  iTriggers               : TriggerArrayType;
  signal  statusEnable            : StatusArrayBitType;
  signal  settingEnable           : SettingArrayBitType;
  signal  triggerEnable           : TriggerArrayType;
  signal  grant                   : WbMasterGrantType;

begin
  SettingRegs <= iSettingRegs;
  Triggers    <= iTriggers;

--=============================================================================
-------------------------------------------------------------------------------
--  Master Round Robin Arbitration
-------------------------------------------------------------------------------
  procArb: process(WbClk,rstZ) is --Round robin arbitration (descending)
    variable vGrant : WbMasterGrantType;
  begin
    if (rstZ='0') then
      vGrant								:= (Others=>'0');
      vGrant(vGrant'left) 	:= '1';
    elsif rising_edge(WbClk) then
      loopGrant: for i in WbMasterType loop
        if vGrant(i)='1' and WbMasterIn(i).Cyc='0' then --else maintain grant
          loopNewGrantA: for j in i to WbMasterType'right loop --last master with cyc=1 will be selected
            if WbMasterIn(j).Cyc='1' then
              vGrant    := (Others=>'0');
              vGrant(j) := '1';
            end if;
          end loop loopNewGrantA;
          if i/=WbMasterType'left then
            loopNewGrantB: for j in WbMasterType'left to WbMasterType'pred(i) loop
              if WbMasterIn(j).Cyc='1' then
                vGrant    := (Others=>'0');
                vGrant(j) := '1';
              end if;
            end loop loopNewGrantB;   --grant only moves after new requester
          end if;
        end if;
      end loop loopGrant;
    end if; --Clk
    grant <= vGrant;
  end process procArb;
--=============================================================================
-------------------------------------------------------------------------------
--  Master Multiplexers
-------------------------------------------------------------------------------
  procWbMasterIn: process(grant,WbMasterIn) is
    variable vSlaveOut    : WbMasterOutType;
  begin
    loopGrantInMux: for i in WbMasterType loop
      vSlaveOut := WbMasterIn(i);
      exit when grant(i)='1';
    end loop loopGrantInMux;
    wbStrobe    <= vSlaveOut.Strobe;
    wbWrEn      <= vSlaveOut.WrEn;
    wbAddr      <= vSlaveOut.Addr;
    wbMData     <= vSlaveOut.Data;
    --wbMDataTag  <= vSlaveOut.DataTag;
    wbCyc       <= vSlaveOut.Cyc;
    --wbCycType   <= vSlaveOut.CycType;
  end process procWbMasterIn;
  procWbMasterOut: process(grant,wbSData,wbAck,wbErr,wbRty) is
  begin
    loopGrantOutMux: for i in grant'range loop
      WbMasterOut(i).Ack  <= grant(i) and wbAck;
      WbMasterOut(i).Err  <= grant(i) and wbErr;
      WbMasterOut(i).Rty  <= grant(i) and wbRty;
      WbMasterOut(i).Data <= wbSData; --Data out can always be active.
    end loop loopGrantOutMux;
  end process procWbMasterOut;

  wbAck <= wbStrobe and validAddress;
  wbErr <= wbStrobe and not(validAddress);
  wbRty <= '0';
  WbRst <= '0';
--=============================================================================
-------------------------------------------------------------------------------
--  Address Decode, Asynchronous
-------------------------------------------------------------------------------
  procAddrDecode: process(wbAddr) is
    variable vValidAddress : std_logic;
  begin
      vValidAddress := '0';
      loopStatusEn: for f in StatusFieldType loop
        if StatusParams(f).Address=wbAddr then
          statusEnable(f) <= '1';
          vValidAddress := '1';
        else
          statusEnable(f) <= '0';
        end if;
      end loop loopStatusEn;
      loopSettingEn: for f in SettingFieldType loop
        if SettingParams(f).Address=wbAddr then
          settingEnable(f)  <= '1';
          vValidAddress := '1';
        else
          settingEnable(f)  <= '0';
        end if;
      end loop loopSettingEn;
      loopTriggerEn: for f in TriggerFieldType loop
        if TriggerParams(f).Address=wbAddr then
          triggerEnable(f)  <= '1';
          vValidAddress := '1';
        else
          triggerEnable(f)  <= '0';
        end if;
      end loop loopTriggerEn;
      validAddress  <= vValidAddress;
  end process procAddrDecode;
--=============================================================================
-------------------------------------------------------------------------------
--  Read
-------------------------------------------------------------------------------
  procRegRead: process(StatusRegs,iSettingRegs,iTriggers,statusEnable,settingEnable,triggerEnable) is
    variable vWbSData : WbDataType;
  begin
    vWbSData  := (Others=>'0');
    loopStatusRegs : for f in StatusFieldType loop
      if statusEnable(f)='1' then
        vWbSData(StatusParams(f).MSBLoc to (StatusParams(f).MSBLoc + StatusParams(f).BitWidth - 1)) := StatusRegs(f)((WbDataBits-StatusParams(f).BitWidth) to WbDataBits-1);
      end if; --Address
    end loop loopStatusRegs;
    loopSettingRegs : for f in SettingFieldType loop
      if settingEnable(f)='1' then
        vWbSData(SettingParams(f).MSBLoc to (SettingParams(f).MSBLoc + SettingParams(f).BitWidth - 1)) := iSettingRegs(f)((WbDataBits-SettingParams(f).BitWidth) to WbDataBits-1);
      end if; --Address
    end loop loopSettingRegs;
    loopTriggerRegs : for f in TriggerFieldType loop
      if triggerEnable(f)='1' then
        vWbSData(TriggerParams(f).BitLoc) := iTriggers(f);
      end if; --Address
    end loop loopTriggerRegs;
    wbSData <= vWbSData;
  end process procRegRead;
--=============================================================================
-------------------------------------------------------------------------------
--  Write, Reset, Clear
-------------------------------------------------------------------------------
  procRegWrite: process(WbClk,rstZ) is
  begin
    if (rstZ='0') then
      loopSettingRegDefault : for f in SettingFieldType loop
        iSettingRegs(f) <= SettingParams(f).Default;
      end loop loopSettingRegDefault;
      loopTriggerRegDefault : for f in TriggerFieldType loop
        iTriggers(f)  <= '0';
      end loop loopTriggerRegDefault;
    elsif rising_edge(WbClk) then
      loopSettingRegWr : for f in SettingFieldType loop
        if settingEnable(f)='1' and wbStrobe='1' and wbWrEn='1' then
          iSettingRegs(f)((WbDataBits-SettingParams(f).BitWidth) to WbDataBits-1) <= wbMData(SettingParams(f).MSBLoc to (SettingParams(f).MSBLoc + SettingParams(f).BitWidth-1));
        end if;
      end loop loopSettingRegWr;
      loopSettingRegRst : for f in SettingFieldType loop
        if SettingRsts(f)='1' then
          iSettingRegs(f) <= SettingParams(f).Default;
        end if;
      end loop loopSettingRegRst;
      loopTriggerRegWr : for f in TriggerFieldType loop
        if triggerEnable(f)='1' and wbStrobe='1' and wbWrEn='1' then
          iTriggers(f)    <= wbMData(TriggerParams(f).BitLoc);
        elsif TriggerClr(f)='1' then
          iTriggers(f)    <= '0';
        end if; --Address or clear
      end loop loopTriggerRegWr;
    end if; --Clk
  end process procRegWrite;

end architecture behavior;