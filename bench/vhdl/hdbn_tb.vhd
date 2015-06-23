-------------------------------------------------------------------------------
-- Title        : hdbn_tb
-- Project      : hdbn
-------------------------------------------------------------------------------
-- File         : hdbn_tb.vhd
-- Author       : Allan Herriman <allanh@opencores.org>
-- Organization : Opencores
-- Created      : 9 Aug 1999
-- Platform     : ?
-- Simulators   : Should work in any VHDL '93 or '00 compliant simulator.
--                (Strict '87 compliant simulators will not work, as some
--                '93 features have been used.)
--                Tested with several versions of Modelsim and Simili.
--                Most recently tested with Modelsim PE 5.6d and Simili 2.1b10
--                on Windows 2000
-- Synthesizers : N/A (this is a testbench)
-- Targets      : N/A (this is a testbench)
-- Dependency   : entities hdbne and hdbnd
-------------------------------------------------------------------------------
-- Description  : testbench for entities hdbne and hdbnd.
--                This is an "assertion based" test.  If it runs to
--                completion (about 16ms) without errors, it has passed.
--
-- Reference    : ITU-T G.703
--
-------------------------------------------------------------------------------
-- Copyright (c) notice
-- http://www.opensource.org/licenses/bsd-license.html
--
-------------------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;


entity hdbn_tb is
    generic (
        HalfWidthOutputs        : boolean := FALSE; -- set TRUE to use 2x clock on encoder
        InjectError             : boolean := FALSE; -- set TRUE to test decoder error detection
        SwapPandN               : boolean := FALSE; -- set TRUE to swap P,N signals between enc and dec
        EncoderType             : integer range 2 to 3 := 3;   -- 3: HDB3 2: HDB2/B3ZS
        PulseActiveState        : std_logic := '1';         -- active state of P and N signals
        LogSpiceFile            : boolean := FALSE;  -- set TRUE to log encoder output in Spice PWL format
        LogFileName             : string := "hdbn.txt";
        StartupTransient        : time := 15 us     -- disables assertions for this long
    );
end hdbn_tb; -- End entity hdbn_tb


architecture tb of hdbn_tb is

    signal  Reset                   :   std_logic := '1';
    signal  Clk                     :   std_logic := '0';
    signal  TxClk                   :   std_logic := '0';
    signal  TxClkEnable             :   std_logic;
    signal  Data                    :   std_logic;  -- encoder input (stimulus)
    signal  DataOut                 :   std_logic;  -- decoder output
    signal  CodeError               :   std_logic;
    signal  P                       :   std_logic;
    signal  N                       :   std_logic;

    signal  PwithErrors             :   std_logic;
    signal  NwithErrors             :   std_logic;

    signal  InjectedError           :   std_logic := '0';

    signal  DataDelayed             :   std_logic;  -- Matches delay of encoder
    signal  DataDelayedSomeMore     :   std_logic;  -- Matches delay of encoder and decoder
    signal  Violation               :   std_logic;

    signal  SimulationFinished      :   boolean := FALSE;

begin


-------------------------------------------------------------------------------
-- Instantiation of entity 'hdbne' - hdbn encoder under test
-------------------------------------------------------------------------------
    eUT : entity work.hdbne
        generic map (
            EncoderType             => EncoderType,
            PulseActiveState        => PulseActiveState
        )
        port map (
            Reset_i                 => Reset,
            Clk_i                   => TxClk,
            ClkEnable_i             => TxClkEnable,
            Data_i                  => Data,
            OutputGate_i            => TxClkEnable,
            P_o                     => P,
            N_o                     => N
        );


-------------------------------------------------------------------------------
-- Instantiation of entity 'hdbnd' - hdbn decoder under test
-------------------------------------------------------------------------------
    dUT : entity work.hdbnd
        generic map (
            EncoderType             => EncoderType,
            PulseActiveState        => PulseActiveState
        )
        port map (
            Reset_i                 => Reset,
            Clk_i                   => Clk,
            ClkEnable_i             => '1',
            P_i                     => PwithErrors,
            N_i                     => NwithErrors,
            Data_o                  => DataOut,
            CodeError_o             => CodeError
        );


-------------------------------------------------------------------------------
-- make two clocks, 4.096MHz and 2.048MHz.
-- Use HalfWidthOutputs to select which one is used for encoder
-- Note: care must be taken to balance delta delays, otherwise races between
-- the clocks may cause unpredictable results.
-------------------------------------------------------------------------------
    MakeClk: process
        variable Clkv     : std_logic := '0';
        variable Clk2xv   : std_logic := '0';
    begin
        wait for 122 ns;
        if SimulationFinished then
            wait until not SimulationFinished;
        end if;
        Clk2xv := not Clk2xv;
        if Clk2xv = '1' then
            Clkv := not Clkv;
        end if;

        -- assign to signals, all in the same delta cycle
        Clk   <= Clkv;
        if HalfWidthOutputs then
            -- run Encoder twice as fast, with every 2nd clock enabled
            TxClk       <= Clk2xv;
            TxClkEnable <= not Clkv;
        else
            -- run Encoder at normal speed, with all clocks enabled
            TxClk       <= Clkv;
            TxClkEnable <= '1';
        end if;

    end process MakeClk;

-------------------------------------------------------------------------------
-- Make async, active high Reset signal
-------------------------------------------------------------------------------
    Reset <= '1', '0' after 50 ns;


-------------------------------------------------------------------------------
-- PROCESS    : StimulusGen, makes pseudo random bit sequence for testing.
-- DESCRIPTION: 15 bit LFSR
-- See ITU-T O.151 for details of this LFSR  (this is the "official" PRBS to
-- use for 2.048Mbps testing).
-------------------------------------------------------------------------------
    StimulusGen: process (Reset, Clk)
        variable shiftreg : Std_logic_vector(14 downto 0) := (others => '0');
    begin
        if Reset = '1' then
            shiftreg := (others => '0');
            Data <= '0';
        elsif rising_edge(Clk) then
          shiftreg := shiftreg(13 downto 0) & (not (shiftreg(14) xor shiftreg(13)));

          if HalfWidthOutputs then
              Data <= shiftreg(1);  -- compensate for earlier sampling in hdbne when run from Clk2x
          else
              Data <= shiftreg(0);
          end if;
          DataDelayed <= shiftreg(3 + EncoderType); -- for violation visualisation
          DataDelayedSomeMore <= shiftreg(5 + 2 * EncoderType); -- for decoder testing

          if shiftreg = (shiftreg'range => '0') then
                report "hdbn simulation finished";
              SimulationFinished <= TRUE after 10 us;
          end if;

        end if;
    end process StimulusGen;


--------------------------------------------------------------------------------
-- optionally inject errors, to test decoder error detection
-- and optionally crossover P&N on the line
--------------------------------------------------------------------------------
    InjectErrors : if InjectError generate
        InjectedError <=  '0',
                          '1' after StartupTransient + 1 us,
                          '0' after StartupTransient + 1.500 us;
    end generate InjectErrors;

    -- normal connection, P->P, N->N
    NoSwapLines : if not SwapPandN generate
        PwithErrors <= P xor InjectedError;
        NwithErrors <= N;
    end generate NoSwapLines;

    -- check that it still works with P and N crossed over
    SwapLines : if SwapPandN generate
        PwithErrors <= N xor InjectedError;
        NwithErrors <= P;
    end generate SwapLines;


-------------------------------------------------------------------------------
-- PROCESS    : Checker
-- DESCRIPTION: Checks aspects of the hdb2/hdb3 encoder against the spec,
--              and checks the decoder against the encoder
-------------------------------------------------------------------------------
    Checker: process (Clk)
        variable RunningSum     :   integer := 0;
        variable ZeroCount      :   integer := 0;
    begin
        if rising_edge(Clk) then

            -- Encoder P and N outputs should never be active at the same time
            assert (not ((P = PulseActiveState) and (N = PulseActiveState)))
                report "Simultaneous P and N Pulse Error on HDBNE output"
                severity error;

            -- There should be no DC component on the line
            if P = PulseActiveState then
                RunningSum := RunningSum + 1;
            elsif N = PulseActiveState then
                RunningSum := RunningSum - 1;
            end if;

            assert RunningSum < 2 and RunningSum > -2
                report "Running Sum Error on HDBNE output"
                severity error;

            -- There shouldn't be too many zeros in a row at encoder output
            if P = PulseActiveState or N = PulseActiveState then
                ZeroCount := 0;
            else
                ZeroCount := ZeroCount + 1;
            end if;

            assert (ZeroCount <= EncoderType) or (now < StartupTransient)
                report "Long String Of Zeros on HDBNE output"
                severity error;

            -- The decoder output should match the encoder input
            assert ((DataDelayedSomeMore xor DataOut) = '0') or (now < StartupTransient)
                report "Decoder Bit Error on HDBND output"
                severity error;

            -- The decoder shouldn't detect any errors
            assert (CodeError = '0') or (now < StartupTransient)
                report "Decoder Code Error on HDBND output"
                severity error;

        end if;
    end process Checker;


    Violation <= DataDelayed xor (P or N);  -- for visualisation only
                                            -- (only useful if HalfWidthOutputs is FALSE)


-------------------------------------------------------------------------------
-- Log values to a file in PSpice "PWL" format, for testing of E1 LIU, etc.
--
-- Note: this process isn't an essential part of the test bench.
--
-- Example spice usage:
--
-- .PARAM  PH = 2.37V       ; G.703 2.048Mbps pulse height
-- .PARAM  PW = 244ns   	; G.703 2.048Mbps pulse width
--
-- Vdrive  1 0 PWL
-- +       TIME_SCALE_FACTOR={PW}
-- +       VALUE_SCALE_FACTOR={PH}
-- + 	FILE hdbn.txt
--
-------------------------------------------------------------------------------
GenLogger : if LogSpiceFile generate

    Logger : process (Clk)
        FILE log_file : text open write_mode IS LogFileName;
        VARIABLE l : line;
        variable LineNumber : integer := 0;
        variable value : integer;
        variable FirstTime : boolean := TRUE;
    begin
        if rising_edge(Clk) then

            if FirstTime then
                -- output (0, 0) as the first line in the file
                write(l, '(' & integer'image(LineNumber) & ", 0)");
                writeline(log_file, l);
                FirstTime := FALSE;
            end if;

            if P = PulseActiveState then
                value := 1;
            elsif N = PulseActiveState then
                value := -1;
            else
                value := 0;
            end if;

            if value = 0 then
                -- don't bother to print it (as the voltage is already 0), but do update the time!
                LineNumber := LineNumber + 2;
            else
                -- ramp the voltage from 0 to the peak value
                write(l, '(' & integer'image(LineNumber) &  ".49, 0)");
                writeline(log_file, l);
                write(l, '(' & integer'image(LineNumber) & ".5, " & integer'image(value) & ')');
                writeline(log_file, l);
                LineNumber := LineNumber + 1;

                -- ramp the voltage from the peak value back to 0
                write(l, '(' & integer'image(LineNumber) & ".49, " & integer'image(value) & ')');
                writeline(log_file, l);
                write(l, '(' & integer'image(LineNumber) & ".5, 0)");
                writeline(log_file, l);
                LineNumber := LineNumber + 1;
            end if;
        end if;
    end process Logger;

end generate GenLogger;


end architecture tb;
-------------------------------------------------------------------------------
-- End of hdbn_tb.vhd
-------------------------------------------------------------------------------
