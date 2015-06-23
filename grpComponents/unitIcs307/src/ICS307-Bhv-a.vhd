-------------------------------------------------------------------------------
-- Title: Serially Programmable Clock Source ICS307
-- Project: FH-Hagenberg/HSSE: SET5
-- Author: Copyright 2006 by Friedrich Seebacher and Markus Pfaff,
-- Linz/Austria/Europe
-------------------------------------------------------------------------------
-- $LastChangedDate: 2007-01-09 08:40:02 +0100 (Di, 09 Jän 2007) $
-- $LastChangedRevision: 415 $
-- $LastChangedBy: pfaff $
-- $HeadURL: file:///C:/pfaff/rpySvn/rpySvnSet5/trunk/Uebung/W06Jg04/Uebung03/unitIcs307/src/ICS307-Bhv-a.vhd $
-- LoginNames: pfaff - Markus Pfaff, Linz/Austria/Europe
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

architecture Bhv of ICS307 is
  signal ShiftIn           : std_ulogic_vector (23 downto 0);
  signal GenClock          : std_ulogic := '0';
  signal Clk1CurrentPeriod : time       := 1 sec / gInputFrequency;
  signal DeltaPeriod       : time       := 0 ps;
  signal Clk1TargetPeriod  : time       := 1 sec / gInputFrequency;
  signal TargetTime        : time       := now;
begin

  -- Shift data in from SPI interface of ICS307
  ShiftInFromSpi : process (iSclk) is
  begin
    if iSclk'event and iSclk = '1' then
      ShiftIn <= ShiftIn(ShiftIn'high-1 downto 0) & iData;
    end if;
  end process ShiftInFromSpi;


  -- The data sheet gives a few constraints we should keep an eye on.
  assert gInputFrequency < 27E6 and gInputFrequency > 5E6
    report "Invalid input frequency value!"
    severity warning;
  
  NewTargetPeriod : process is
    -- The default value the ICS307 has after power up
    variable vDataReceived              : std_ulogic_vector (23 downto 0) := X"230406";
    variable vOutDiv                    : natural                         := 1;
    variable vVdw                       : natural                         := 1;
    variable vRdw                       : natural                         := 1;
    variable vCyclesToSpendInTransition : natural;
  begin
    wait until iStrobe = '1';
    wait until iStrobe = '0';
    -- Latch what you shifted up until now.
    vDataReceived := ShiftIn;
    -- The divider values are part of the bit field latched in.
    case vDataReceived(18 downto 16) is
      when "000"  => vOutDiv := 10;
      when "001"  => vOutDiv := 2;
      when "010"  => vOutDiv := 8;
      when "011"  => vOutDiv := 4;
      when "100"  => vOutDiv := 5;
      when "101"  => vOutDiv := 7;
      when "110"  => vOutDiv := 3;
      when "111"  => vOutDiv := 6;
      when others =>
        report "OD has no valid value!"
          severity warning;
    end case;
    vVdw := to_integer(unsigned(vDataReceived(15 downto 7)));
    assert vVdw > 3
      report "Vdw is required to be greater than 3!"
      severity warning;
    assert vVdw < 512
      report "Vdw required to be smaller than 512"
      severity warning;
    vRdw := to_integer(unsigned(vDataReceived(6 downto 0)));
    assert vRdw > 0
      report "Rdw required to be greater than 0!"
      severity warning;
    Clk1TargetPeriod <=
      ((1 sec) * ((vRdw+2)*vOutDiv)) / (gInputFrequency*2*(8+vVdw));
    wait for 0 ns;
    TargetTime <=
      now + gClkFrequcenyTransitionTime;
    assert (gClkFrequcenyTransitionTime > 1 us and gClkFrequcenyTransitionTime <= 10 ms)
      report "Frequency transition time has to be in the range ]0 ms,10 ms]!"
      severity error;
    -- If the period would be the average of the current and the target period,
    -- how many cycle would transition take?
    vCyclesToSpendInTransition :=
      gClkFrequcenyTransitionTime /
      ((Clk1TargetPeriod+Clk1CurrentPeriod)/2);
    -- What is the time difference from one cycle to the next? It maybe negative!
    DeltaPeriod <= (Clk1TargetPeriod - Clk1CurrentPeriod) / vCyclesToSpendInTransition;
  end process NewTargetPeriod;


  -- From the moment the data is latched in the clock frequency makes a smooth
  -- transition from the current frequency to the programmed frequency in
  -- gClkFrequcenyTransitionTime
  GenClkCycle : process is
    variable vTimeToSpendInTransition : time := 0 ps;
    variable vClk1CurrentPeriod       : time := 1 sec / gInputFrequency;
  begin
    -- How long to go until the target period should be reached?
    if TargetTime > now then
      vTimeToSpendInTransition := TargetTime-now;
    else
      vTimeToSpendInTransition := 0 ps;
    end if;
    if vTimeToSpendInTransition > Clk1TargetPeriod then
      -- Determine the current period
      -- Adapt the current period to get a little closer to the target value.
      vClk1CurrentPeriod := vClk1CurrentPeriod + DeltaPeriod;
    else
      vClk1CurrentPeriod := Clk1TargetPeriod;
    end if;
    -- Make current period available to other processes
    Clk1CurrentPeriod <= vClk1CurrentPeriod;

    -- Generate the internal clock.
    oClk1 <= '0';
    wait for vClk1CurrentPeriod/2;
    oClk1 <= '1';
    wait for vClk1CurrentPeriod/2;
  end process GenClkCycle;
  
end Bhv;  -- of ICS307





