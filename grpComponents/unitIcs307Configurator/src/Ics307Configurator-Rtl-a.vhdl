-------------------------------------------------------------------------------
-- Title: 
-- Project: FH-Hagenberg/HSSE: Sandbox X general use IP
-- Author: Copyright 2006 by Markus Pfaff, Linz/Austria/Europe
-------------------------------------------------------------------------------
-- $LastChangedDate: 2007-01-09 08:40:02 +0100 (Di, 09 Jän 2007) $
-- $LastChangedRevision: 415 $
-- $LastChangedBy: pfaff $
-- $HeadURL: file:///C:/pfaff/rpySvn/rpySvnSet5/trunk/Uebung/W06Jg04/Uebung03/unitIcs307Configurator/src/Ics307Configurator-Rtl-a.vhd $
-- LoginNames: pfaff - Markus Pfaff, Linz/Austria/Europe
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

architecture Rtl of Ics307Configurator is

  -----------------------------------------------------------------------------
  -- register definition
  -----------------------------------------------------------------------------
  type    aActivity is (Transmitting, LatchingIn, Completed);
  type    aRegion is (RegionC, RegionTTL, RegionF, RegionS, RegionV, RegionR);
  subtype aBitIdx is integer range 0 to 8;
  subtype aCycleCtr is integer range 0 to 7;

  type aRegSet is record
    Activity : aActivity;
    Region   : aRegion;
    BitIdx   : aBitIdx;
    CycleCtr : aCycleCtr;
    Sclk     : std_ulogic;
    Data     : std_ulogic;
  end record aRegSet;

  signal R, NxR : aRegSet;

  constant cRinitVal : aRegSet := (
    Activity => Transmitting,
    Region   => RegionC,
    BitIdx   => aBitIdx'low,
    CycleCtr => aCycleCtr'low,
    Sclk     => '0',
    Data     => '0'
    );

begin

  ------------
  -- Registers
  ------------
  Registers : process(iClk, inResetAsync)
  begin
    if (inResetAsync = cnActivated) then
      R <= cRinitVal;
    elsif ((iClk'event) and (iClk = '1')) then
      R <= NxR;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Nx State and Output Logic: Combinatorial
  -----------------------------------------------------------------------------
  NxStateAndOutput : process (
    R
    )

  begin

    ---------------------------------------------------------------------------
    -- Set Nx State Defaults
    ---------------------------------------------------------------------------
    NxR <= R;

    ---------------------------------------------------------------------------
    -- Set Output Defaults
    ---------------------------------------------------------------------------
    oStrobe <= cInactivated;

    ---------------------------------------------------------------------------
    -- Consider Actual States and Inputs
    ---------------------------------------------------------------------------
    case R.Activity is
      
      when Transmitting =>
        -- Generating Sclk
        if R.CycleCtr /= aCycleCtr'high then
          NxR.CycleCtr <= R.CycleCtr + 1;
        else
          NxR.CycleCtr <= 0;
          if R.Sclk = '0' then
            -- rising edge of Sclk
            NxR.Sclk <= '1';
          else
            -- falling edge of Sclk
            NxR.Sclk <= '0';
            -- Adjust Region and BitIdx
            if R.BitIdx = 0 then
              -- The order of regions is given in the data sheet on page 5.
              case R.Region is
                when RegionC =>
                  NxR.Region <= RegionTTL;
                when RegionTTL =>
                  NxR.BitIdx <= gClkFunctionSelect_R'left;
                  NxR.Region <= RegionF;
                when RegionF =>
                  NxR.BitIdx <= gOutputDivide_S'left;
                  NxR.Region <= RegionS;
                when RegionS =>
                  NxR.BitIdx <= gVcoDividerWord_VDW'left;
                  NxR.Region <= RegionV;
                when RegionV =>
                  NxR.BitIdx <= gReferenceDivider_RDW'left;
                  NxR.Region <= RegionR;
                when RegionR =>
                  NxR.Activity <= LatchingIn;
              end case;
            else
              NxR.BitIdx <= R.BitIdx - 1;
            end if;
          end if;
        end if;
        
      when LatchingIn =>
        oStrobe <= cActivated;
        if R.CycleCtr /= aCycleCtr'high then
          NxR.CycleCtr <= R.CycleCtr +1;
        else
          NxR.Activity <= Completed;
        end if;

      when Completed =>
        null;
        
    end case;

    -- Determine data output
    case R.Region is
      -- The order of regions is given in the data sheet on page 5.
      when RegionC =>
        oData <= gCrystalLoadCapacitance_C (R.BitIdx);
      when RegionTTL =>
        oData <= gOutputDutyCycleVoltage_TTL;
      when RegionF =>
        oData <= gClkFunctionSelect_R(R.BitIdx);
      when RegionS =>
        oData <= gOutputDivide_S (R.BitIdx);
      when RegionV =>
        oData <= gVcoDividerWord_VDW (R.BitIdx);
      when RegionR =>
        oData <= gReferenceDivider_RDW (R.BitIdx);
    end case;
    
  end process NxStateAndOutput;

  oSclk <= R.Sclk;
  
end Rtl;
