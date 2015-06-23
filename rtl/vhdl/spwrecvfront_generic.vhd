--
--  Front-end for SpaceWire Receiver
--
--  This entity samples the input signals DataIn and StrobeIn to detect
--  valid bit transitions. Received bits are handed to the application.
--
--  Inputs are sampled on the rising edge of the system clock, therefore
--  the maximum bitrate of the incoming signal must be significantly lower
--  than system clock frequency.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spwrecvfront_generic is

    port (
        -- System clock.
        clk:        in  std_logic;

        -- High to enable receiver; low to disable and reset receiver.
        rxen:       in  std_logic;

        -- High if there has been recent activity on the input lines.
        inact:      out std_logic;

        -- High if inbits contains a valid received bit.
        -- If inbvalid='1', the application must sample inbits on
        -- the rising edge of clk.
        inbvalid:   out std_logic;

        -- Received bit
        inbits:     out std_logic_vector(0 downto 0);

        -- Data In signal from SpaceWire bus.
        spw_di:     in  std_logic;

        -- Strobe In signal from SpaceWire bus.
        spw_si:     in  std_logic );

end entity spwrecvfront_generic;

architecture spwrecvfront_arch of spwrecvfront_generic is

    -- input flip-flops
    signal s_spwdi1:    std_ulogic;
    signal s_spwsi1:    std_ulogic;
    signal s_spwdi2:    std_ulogic;
    signal s_spwsi2:    std_ulogic;

    -- data/strobe decoding
    signal s_spwsi3:    std_ulogic;

    -- output registers
    signal s_inbvalid:  std_ulogic;
    signal s_inbit:     std_ulogic;

begin

    -- drive outputs
    inact       <= s_inbvalid;
    inbvalid    <= s_inbvalid;
    inbits(0)   <= s_inbit;

    -- synchronous process
    process (clk) is
    begin
        if rising_edge(clk) then

            -- sample input signal
            s_spwdi1    <= spw_di;
            s_spwsi1    <= spw_si;

            -- more flip-flops for safe synchronization
            s_spwdi2    <= s_spwdi1;
            s_spwsi2    <= s_spwsi1;

            -- keep strobe signal for data/strobe decoding
            s_spwsi3    <= s_spwsi2;

            -- keep data bit for data/strobe decoding
            s_inbit     <= s_spwdi2;

            if rxen = '1' then
                -- data/strobe decoding
                s_inbvalid  <= s_spwdi2 xor s_spwsi2 xor s_inbit xor s_spwsi3;
            else
                -- reset receiver
                s_inbvalid  <= '0';
            end if;

        end if;
    end process;

end architecture spwrecvfront_arch;
