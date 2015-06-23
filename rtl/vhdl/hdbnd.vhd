-------------------------------------------------------------------------------
-- Title        : hdbnd
-- Project      : hdbn
-------------------------------------------------------------------------------
-- File         : hdbnd.vhd
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
-- Dependency   : None.  Complementary encoder is hdb3e.
-------------------------------------------------------------------------------
-- Description  : HDB3 or HDB2 (B3ZS) decoder.
--                Note: this module does not include clock recovery.
--                A separate CDR (Clock and Data Recovery) circuit must be
--                used.
--
--  HDB3 is typically used to encode data at 2.048, 8.448 and 34.368Mb/s
--  B3ZS is typically used to encode data at 44.736Mb/s
--  These encodings are polarity insensitive, so the P and N inputs may be
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


entity hdbnd is
    generic (
        EncoderType             : integer range 2 to 3 := 3;   -- 3: HDB3 2: HDB2/B3ZS
        PulseActiveState        : std_logic := '1'          -- active state of P and N inputs
    );
    port (
        Reset_i                 : in    std_logic := '0';   -- active high async reset
        Clk_i                   : in    std_logic;          -- rising edge clock
        ClkEnable_i             : in    std_logic := '1';   -- active high clock enable
        P_i                     : in    std_logic;          -- +ve pulse input
        N_i                     : in    std_logic;          -- -ve pulse input
        Data_o                  : out   std_logic;          -- active high data output
        CodeError_o             : out   std_logic           -- active high error indicator
    );
end hdbnd; -- End entity hdbnd


architecture rtl of hdbnd is

    signal  PinRaw                  : std_logic;    -- registered P input
    signal  NinRaw                  : std_logic;    -- registered N input
    signal  Pin                     : std_logic;    -- registered P input (with polarity corrected)
    signal  Nin                     : std_logic;    -- registered N input (with polarity corrected)
    signal  Violation               : std_logic;    -- pulse violation detected
    signal  LastPulsePolarity       : std_logic;    -- last pulse sense 1=P, 0=N
    signal  LastViolationPolarity   : std_logic;    -- last violation sense "

    -- shift register bits (to align data with violations, so we can delete them)
    signal  Q1                      : std_logic;
    signal  Q2                      : std_logic;
    signal  Q3                      : std_logic;

    -- signals used for calculating CodeError
    signal  ViolationError          : std_logic;    -- indicates bad violation
    signal  ZeroCount               : integer range 0 to 3; -- counts 0s in input
    signal  TooManyZeros            : std_logic;    -- indicates 4 consecutive zeros detected
    signal  PulseError              : std_logic;    -- indicates simultaneous P and N pulse

begin

-------------------------------------------------------------------------------
-- PROCESS    : RegisterInput
-- DESCRIPTION: DFF to register P and N inputs (reduces fan-in, etc)
--              Most applications of this core will be taking inputs from
--              off-chip, so these FF will be in the I/O blocks.
-- Metastability issues: None.
--  Either (1) the external CDR provides adequate
--  timing margin (which ensures no metastability issues)
--  or (2) it doesn't provide adequate timing margin (which could happen
--  if the input cable is unplugged) and any metastable states are irrelevant,
--  as the downstream decoding logic is free of lockup states,
--  and will recover within a few clocks once the
--  CDR is providing normal input again.
-------------------------------------------------------------------------------
    RegisterInput: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            PinRaw <= '0';
            NinRaw <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                PinRaw <= to_X01(P_i);
                NinRaw <= to_X01(N_i);
            end if;
        end if;
    end process RegisterInput;


    --  Restore active low pulse inputs to active high for internal use.
    Pin <= PinRaw xor (not PulseActiveState);
    Nin <= NinRaw xor (not PulseActiveState);


-------------------------------------------------------------------------------
-- PROCESS    : DecodeViolation
-- DESCRIPTION: Work out whether there has been a pulse violation, and
--              remember the sense of the last input pulse.
-------------------------------------------------------------------------------
    DecodeViolation: process (Reset_i, Clk_i)
        variable tmp : std_logic_vector(1 downto 0);
    begin
        if Reset_i = '1' then
            LastPulsePolarity <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                tmp := Pin & Nin;
                case tmp is
                    when "00"   =>   LastPulsePolarity <= LastPulsePolarity; --hold
                    when "10"   =>   LastPulsePolarity <= '1';   -- set
                    when "01"   =>   LastPulsePolarity <= '0';   -- reset
                    when others =>   LastPulsePolarity <= '0';   -- don't care
                end case;
            end if;
        end if;
    end process DecodeViolation;

    Violation <= (Pin and LastPulsePolarity) or (Nin and (not LastPulsePolarity));


-------------------------------------------------------------------------------
-- PROCESS    : DelayData
-- DESCRIPTION: Delay the data input so that it lines up with the violation
-- signal, so we can remove the B bit (in process DecodeData).
-------------------------------------------------------------------------------
    DelayData: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            Q1 <= '0';
            Q2 <= '0';
            Q3 <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                Q1 <=  (Pin or Nin) and (not Violation); -- delete V bit
                Q2 <= Q1;
                if EncoderType = 3 then
                    -- HDB3, delay by 3 clocks
                    Q3 <= Q2;
                else
                    -- HDB2, delay by 2 clocks
                    Q3 <= Q1;   -- skip Q2
                end if;
            end if;
        end if;
    end process DelayData;


-------------------------------------------------------------------------------
-- PROCESS    : DecodeData
-- DESCRIPTION: remove B bits from data, and register output
-------------------------------------------------------------------------------
    DecodeData: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            Data_o <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                Data_o <= Q3 and (not Violation); -- delete B bit
            end if;
        end if;
    end process DecodeData;


-------------------------------------------------------------------------------
-- PROCESS    : CountZeros
-- DESCRIPTION: count number of contiguous zeros in input (mod 3 or 4)
-------------------------------------------------------------------------------
    CountZeros: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            ZeroCount <= 0;
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                if (Pin or Nin) = '1' then
                    ZeroCount <= 0;             -- have seen a 1, reset count
                elsif ZeroCount >= EncoderType then
                    ZeroCount <= EncoderType;   -- hold
                else
                    ZeroCount <= ZeroCount + 1; -- increment
                end if;
            end if;
        end if;
    end process CountZeros;


-------------------------------------------------------------------------------
-- PROCESS    : DecodeViolationError
-- DESCRIPTION: Remember the polarity of this violation, so that we can work
--              out whether the next violation is an error.
-------------------------------------------------------------------------------
    DecodeViolationError: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            LastViolationPolarity <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                if Violation = '1' then
                    LastViolationPolarity <= LastPulsePolarity;
                else
                    LastViolationPolarity <= LastViolationPolarity; -- latch
                end if;
            end if;
        end if;
    end process DecodeViolationError;


-------------------------------------------------------------------------------
-- The follow logic checks for various error conditions.
-------------------------------------------------------------------------------

    ViolationError <= Violation and (not (Pin xor LastViolationPolarity));

    PulseError <= Pin and Nin;

    TooManyZeros <= (not (Pin or Nin)) when (ZeroCount = EncoderType) else '0';


-------------------------------------------------------------------------------
-- PROCESS    : RegisterCodeError
-- DESCRIPTION: combine all error signals and register the output
-------------------------------------------------------------------------------
    RegisterCodeError: process (Reset_i, Clk_i)
    begin
        if Reset_i = '1' then
            CodeError_o <= '0';
        elsif rising_edge(Clk_i) then
            if ClkEnable_i = '1' then
                CodeError_o <= ViolationError or PulseError or TooManyZeros;
            end if;
        end if;
    end process RegisterCodeError;


end rtl; -- End architecture rtl;
-------------------------------------------------------------------------------
-- End of hdbnd.vhd
-------------------------------------------------------------------------------
