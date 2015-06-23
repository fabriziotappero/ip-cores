--Propery of Tecphos Inc.  See License.txt for license details
--Latest version of all project files available at http://opencores.org/project,wrimm
--See WrimmManual.pdf for the Wishbone Datasheet and implementation details.
--See wrimm subversion project for version history

library ieee;
  use ieee.NUMERIC_STD.all;
  use ieee.std_logic_1164.all;
  use std.textio.all;

  use work.WrimmPackage.all;

entity WrimmTestBench is
end WrimmTestBench;

architecture TbArch of WrimmTestBench is

  component Wrimm is
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
      rstZ              : in  std_logic);        --Asynchronous reset
  end component Wrimm;
  
  signal wbMastersOut           : WbSlaveOutArray;
  signal wbMastersIn            : WbMasterOutArray;
  signal statusRegs             : StatusArrayType;
  signal settingRegs            : SettingArrayType;
  signal settingRsts            : SettingArrayBitType;
  signal triggers               : TriggerArrayType;
  signal triggerClrs            : TriggerArrayType;
  
  signal rstZ                   : std_logic;
  signal WishboneClock          : std_logic;
  signal WishBoneReset          : std_logic;

  constant clkPeriod          : time := 0.01 us; --100 MHz

begin
  procClk: process
  begin
    if WishBoneClock='1' then
      WishBoneClock <= '0';
    else
      WishBoneClock <= '1';
    end if;
    wait for clkPeriod/2;
  end process procClk;
  
  procRstZ: process
  begin
    rstZ  <= '0';
    wait for 10 ns;
    rstZ  <= '1';
    wait;
  end process procRstZ;

  instWrimm: Wrimm
  port map(
    WbClk             => WishboneClock,
    WbRst             => WishboneReset,
    WbMasterIn        => wbMastersIn,
    WbMasterOut       => wbMastersOut,
    --WbSlaveIn       => ,
    --WbSlaveOut      => ,
    StatusRegs        => statusRegs,
    SettingRegs       => settingRegs,
    SettingRsts       => settingRsts,
    Triggers          => triggers,
    TriggerClr        => triggerClrs,
    rstZ              => rstZ);
  
  procStatusStim: process(WishboneClock) is
	  variable statusCount : unsigned (0 to WbDataBits-1) := (Others=>'0');
	begin
		if rising_edge(WishboneClock) then
			loopStatusAssign: for i in StatusFieldType loop
				statusRegs(i) <= std_logic_vector(statusCount);
				statusCount	:= statusCount + 1;	--actual values don't matter, just generating unique values.
			end loop loopStatusAssign;
		end if;	--Clk
	end process procStatusStim;
	
	procStatusVerify: process(WishboneClock) is
		variable L : line;
	begin
		if rising_edge(WishBoneClock) then
			loopMasters: for i in WbMasterType loop
				if wbMastersOut(i).Ack='1' and wbMastersIn(i).WrEn='0' then --valid Ack to Read request
					loopStatusRegs: for j in StatusFieldType loop
							if StatusParams(j).Address=wbMastersIn(i).Addr then		--correct address
								report "Evaluating Status Read" severity NOTE;
								assert (statusRegs(j)=wbMastersOut(i).data) report "Invalid Status Register Read" severity Warning;
							end if;
					end loop loopStatusRegs;
				end if;	-- valid Ack
			end loop loopMasters;
		end if;	--Clk
	end process procStatusVerify;
	
	procSettingResets: process(WishboneClock) is
		variable resetVector	: unsigned(0 to settingRsts'length-1) := (Others=>'0');
		variable resetCount		: integer := 0;
		variable resetIndex		: integer := 0;
	begin
		if rising_edge(WishboneClock) then
			if resetCount=20 then
				resetCount 	:= 0;
				resetVector := resetVector+1;
				resetIndex	:= 0;
				loopSetRsts: for i in SettingFieldType loop
					settingRsts(i)	<= resetVector(resetIndex);
					resetIndex := resetIndex + 1;
				end loop loopSetRsts;
			else
				resetCount 	:= resetCount + 1;
				settingRsts	<= (Others=>'0');
			end if;
		end if;	--Clk
	end process procSettingResets;
	
	procSettingMonitor: process(WishboneClock,rstZ) is
		variable settingTBRegs	: SettingArrayType;
	begin
		if (rstZ='0') then
			loopSettingRstZ: for i in SettingFieldType loop
				settingTBRegs(i) := SettingParams(i).Default;
			end loop loopSettingRstZ;
		elsif rising_edge(WishboneClock) then
			loopSettingRegsCheck : for k in SettingFieldType loop
				assert (settingTBRegs(k)=settingRegs(k))	report "Setting Reg Mismatch" severity Warning;
			end loop loopSettingRegsCheck;
			loopMasters: for i in WbMasterType loop 												--valid Ack
				if wbMastersOut(i).Ack='1' then
					if wbMastersIn(i).WrEn='1' then 														-- Write request
						loopSettingWriteRegs: for j in SettingFieldType loop
							if SettingParams(j).Address=wbMastersIn(i).Addr then		--valid setting address
								report "Writing Setting Reg";
								settingTBRegs(j) := wbMastersIn(i).data;
							end if;	--Address match
						end loop loopSettingWriteRegs;
					else																												-- Read request
						loopSettingReadRegs: for j in SettingFieldType loop
							if SettingParams(j).Address=wbMastersIn(i).Addr then		--valid setting address
								report "Reading Setting Reg";
								assert (wbMastersOut(i).data=settingTBRegs(j)) report "Setting Read Mismatch" severity Warning;
							end if;	--Address match
						end loop loopSettingReadRegs;
					end if;	--WrEn
				end if;	--Ack to write
			end loop loopMasters;
			loopSettingResets: for i in SettingFieldType loop
				if settingRsts(i)='1' then
					settingTBRegs(i) := SettingParams(i).Default;
				end if;
			end loop loopSettingResets;
		end if;	--Clk
	end process procSettingMonitor;

  procMasterStim: process(WishboneClock,rstZ) is
    variable rCount 		: unsigned(0 to WbAddrBits) := (Others=>'0');
    variable rData  		: unsigned(0 to WbDataBits-1) := (Others=>'0');
    variable burstCount : integer := 5;
    variable idleCount	: integer := 4;
  begin
    if rising_edge(WishboneClock) then
			rData				:= rData + 1;
      if WbMastersOut(Q).Ack='1' or WbMastersOut(Q).Rty='1' or WbMastersOut(Q).Err='1' then
        rCount			:= rCount + 1;
	      burstCount	:= burstcount - 1;
	      if burstCount=0 then
		      idleCount := 3;
		    end if;
      elsif idleCount=0 then
        if burstCount=0 then
          burstCount := 4;
        end if;
      else
        idleCount := idleCount - 1;
      end if;

			wbMastersIn(Q).Data <= std_logic_vector(rData);
	    wbMastersIn(Q).Addr <= std_logic_vector(rCount(1 to WbAddrBits));
	    wbMastersIn(Q).WrEn	<= rCount(0);	--read then write
	    if burstCount=0 then
				wbMastersIn(Q).Strobe <= '0';
			  wbMastersIn(Q).Cyc		<= '0';
			else
				wbMastersIn(Q).Strobe <= '1';
				wbMastersIn(Q).Cyc		<= '1';
		  end if;
    end if; --Clk
  end process procMasterStim;

end TbArch;
