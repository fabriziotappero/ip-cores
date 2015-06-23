--
--  Double flip-flop synchronizer.
--
--  This entity is used to safely capture asynchronous signals.
--
--  An implementation may assign additional constraints to this entity
--  in order to reduce the probability of meta-stability issues.
--  For example, an extra tight timing constraint could be placed on
--  the data path from syncdff_ff1 to syncdff_ff2 to ensure that
--  meta-stability of ff1 is resolved before ff2 captures the signal.
--

library ieee;
use ieee.std_logic_1164.all;

entity syncdff is

    port (
        clk:        in  std_logic;          -- clock (destination domain)
        rst:        in  std_logic;          -- asynchronous reset, active-high
        di:         in  std_logic;          -- input data
        do:         out std_logic           -- output data
    );

    -- Turn off register replication in XST.
    attribute REGISTER_DUPLICATION: string;
    attribute REGISTER_DUPLICATION of syncdff: entity is "NO";

end entity syncdff;

architecture syncdff_arch of syncdff is

    -- flip-flops
    signal syncdff_ff1: std_ulogic := '0';
    signal syncdff_ff2: std_ulogic := '0';

    -- Turn of shift-register extraction in XST.
    attribute SHIFT_EXTRACT: string;
    attribute SHIFT_EXTRACT of syncdff_ff1: signal is "NO";
    attribute SHIFT_EXTRACT of syncdff_ff2: signal is "NO";

    -- Tell XST to place both flip-flops in the same slice.
    attribute RLOC: string;
    attribute RLOC of syncdff_ff1: signal is "X0Y0";
    attribute RLOC of syncdff_ff2: signal is "X0Y0";

    -- Tell XST to keep the flip-flop net names to be used in timing constraints.
    attribute KEEP: string;
    attribute KEEP of syncdff_ff1: signal is "SOFT";
    attribute KEEP of syncdff_ff2: signal is "SOFT";

begin

    -- second flip-flop drives the output signal
    do <= syncdff_ff2;

    process (clk, rst) is
    begin
        if rst = '1' then
            -- asynchronous reset
            syncdff_ff1 <= '0';
            syncdff_ff2 <= '0';
        elsif rising_edge(clk) then
            -- data synchronization
            syncdff_ff1 <= di;
            syncdff_ff2 <= syncdff_ff1;
        end if;
    end process;

end architecture syncdff_arch;
