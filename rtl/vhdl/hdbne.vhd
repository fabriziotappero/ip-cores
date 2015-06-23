-------------------------------------------------------------------------------
-- Title        : hdbne
-- Project      : hdbn
-------------------------------------------------------------------------------
-- File         : hdbne.vhd
-- Author       : Allan Herriman <allanh@opencores.org>
-- Organization : Opencores
-- Created      : 9 Aug 1999
-- Platform     : ?
-- Simulators   : Any VHDL '87, '93 or '00 compliant simulator will work.
--                Tested with several versions of Modelsim and Simili.
-- Synthesizers : Any VHDL compliant synthesiser will work (tested with
--                Synplify Pro and Leonardo).
-- Targets      : Anything (contains no target dependent features except
--                combinatorial logic and D flip flops with async
--                reset or set).
-- Dependency   : None.  Complementary decoder is hdb3d.
-------------------------------------------------------------------------------
-- Description  : HDB3 or HDB2 (B3ZS) encoder.
--                P and N outputs are full width by default.
--  Half width pulses can be created by using a double rate clock and
--  strobing ClkEnable and OutputEnable appropriately (high every second clock).
--
--  HDB3 is typically used to encode data at 2.048, 8.448 and 34.368Mb/s
--  B3ZS is typically used to encode data at 44.736Mb/s
--  The outputs will require pulse shaping if used to drive the line.
--  These encodings are polarity insensitive, so the P and N outputs may be
--  used interchangeably (swapped).
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


entity hdbne is
    generic (
        EncoderType             : integer range 2 to 3 := 3;   -- 3: HDB3 2: HDB2/B3ZS
        PulseActiveState        : std_logic := '1'          -- active state of P and N outputs
    );
    port (
        Reset_i                 : in    std_logic := '0';   -- active high async reset
        Clk_i                   : in    std_logic;          -- rising edge clock
        ClkEnable_i             : in    std_logic := '1';   -- active high clock enable
        Data_i                  : in    std_logic;          -- active high data input
        OutputGate_i            : in    std_logic := '1';   -- '0' forces P and N to not PulseActiveState (synchronously, but ignoring ClkEnable)
        P_o                     : out   std_logic;          -- encoded +ve pulse output
        N_o                     : out   std_logic           -- encoded -ve pulse output
    );
end hdbne; -- End entity hdbne


architecture rtl of hdbne is

    signal  Q1                  : std_logic;    -- Q1 through Q5 form a shift
    signal  Q2                  : std_logic;    --   register for aligning
    signal  Q3                  : std_logic;    --   the data so we can insert
    signal  Q4                  : std_logic;    --   the violations
    signal  Q5                  : std_logic;

    signal  AMI                 : std_logic;    -- sense of pulse (P or N)
    signal  ViolationType       : std_logic;    -- sense of violation
    signal  ZeroCount           : integer range 0 to 3; -- counts 0s in input
    signal  ZeroString          : std_logic;    -- goes to '1' when 3 or 4 0s seen
    signal  ZeroStringDelayed   : std_logic;    -- above delayed by 1 clock

begin

-------------------------------------------------------------------------------
-- PROCESS    : RegisterInput
-- DESCRIPTION: DFF (Q1) to register input data (reduces fan-in, etc)
-------------------------------------------------------------------------------
    RegisterInput: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            Q1 <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                Q1 <= to_X01(Data_i);
            end if;
        end if;
    end process RegisterInput;


-------------------------------------------------------------------------------
-- PROCESS    : CountZeros
-- DESCRIPTION: count number of contiguous zeros in input (mod 4 or mod 3)
-------------------------------------------------------------------------------
    CountZeros: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            ZeroCount <= 0;
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                if Q1 = '1' then
                    ZeroCount <= 0;                 -- have seen a 1, reset count
                elsif ZeroCount >= EncoderType then
                    ZeroCount <= 0;                 -- increment modulo 3 or 4
                else
                    ZeroCount <= ZeroCount + 1;     -- increment
                end if;
            end if;
        end if;
    end process CountZeros;


-------------------------------------------------------------------------------
-- PROCESS    : DecodeCount (combinatorial)
-- DESCRIPTION: decode ZeroCount to indicate when string of 3 or 4 zeros is present
--  Note: this process is not clocked
-------------------------------------------------------------------------------
    DecodeCount: process (Q1, ZeroCount)
    begin
        if ZeroCount = EncoderType and Q1 = '0' then
            ZeroString <= '1';
        else
            ZeroString <= '0';
        end if;
    end process DecodeCount;


-------------------------------------------------------------------------------
-- PROCESS    : RegisterZeroString
-- DESCRIPTION: DFF to register the ZeroString signal
-------------------------------------------------------------------------------
    RegisterZeroString: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            ZeroStringDelayed <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                ZeroStringDelayed <= ZeroString;
            end if;
        end if;
    end process RegisterZeroString;


-------------------------------------------------------------------------------
-- PROCESS    : DelayData
-- DESCRIPTION: insert 1 if needed for violation, and delay data by 2 or 3 clocks
--  to line up with ZeroString detection.
-------------------------------------------------------------------------------
    DelayData: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            Q2 <= '0';
            Q3 <= '0';
            Q4 <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                Q2 <= Q1 or ZeroString;  -- insert Violation bit
                Q3 <= Q2;
                if EncoderType = 3 then
                    -- HDB3, delay by 3 clocks
                    Q4 <= Q3;
                else
                    -- HDB2, delay by 2 clocks
                    Q4 <= Q2;   -- skip Q3
                end if;
            end if;
        end if;
    end process DelayData;


-------------------------------------------------------------------------------
-- PROCESS    : InsertBBit
-- DESCRIPTION: Delay Q4 by one clock, and insert B bit if needed.
-------------------------------------------------------------------------------
    InsertBBit: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            Q5 <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                Q5 <= Q4 or (ZeroString and (not ViolationType));
            end if;
        end if;
    end process InsertBBit;


-------------------------------------------------------------------------------
-- PROCESS    : ToggleViolationType
-- DESCRIPTION: Toggle ViolationType whenever Q5 is 1
-------------------------------------------------------------------------------
    ToggleViolationType: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            ViolationType <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                ViolationType <= ViolationType xor Q5;
            end if;
        end if;
    end process ToggleViolationType;


-------------------------------------------------------------------------------
-- PROCESS    : AMIFlipFlop
-- DESCRIPTION: toggle AMI to alternate P and N pulses.  Force a violation (no
-- toggle) occasionally.
-------------------------------------------------------------------------------
    AMIFlipFlop: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            AMI <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                AMI <= AMI xor (Q5 and (ViolationType nand (ZeroString or ZeroStringDelayed)));
            end if;
        end if;
    end process AMIFlipFlop;


-------------------------------------------------------------------------------
-- PROCESS    : MakePandNPulses
-- DESCRIPTION: Gate Q5 with AMI to produce the P and N outputs
--  Note that OutputEnable overrides ClkEnable, to allow creation of
--  half width pulses.
-- The flip flops P and N will drive the outputs to the LIU, and these
-- flip flops should be in the IOBs in an FPGA.  Clk to output delay
-- should be matched for P and N to avoid pulse shape distortion at the LIU
-- output.
-------------------------------------------------------------------------------
    MakePandNPulses: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            P_o <= not PulseActiveState;
            N_o <= not PulseActiveState;
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' or OutputGate_i /= '1' then
                if OutputGate_i /= '1' then
                    -- force output to '0'
                    P_o <= not PulseActiveState;
                    N_o <= not PulseActiveState;
                else
                    -- normal operation
                    if Q5 = '1' then
                        if AMI = '1' then
                            -- output '1' on P
                            P_o <= PulseActiveState;
                            N_o <= not PulseActiveState;
                        else
                            -- output '1' on N
                            P_o <= not PulseActiveState;
                            N_o <= PulseActiveState;
                        end if;
                    else
                        -- output '0'
                        P_o <= not PulseActiveState;
                        N_o <= not PulseActiveState;
                    end if;
                end if;
            end if;
        end if;
    end process MakePandNPulses;


end rtl; -- End architecture rtl;
-------------------------------------------------------------------------------
-- End of hdbne.vhd
-------------------------------------------------------------------------------
