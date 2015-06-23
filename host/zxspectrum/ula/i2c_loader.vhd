-- ZX Spectrum for Altera DE1
--
-- Copyright (c) 2009-2010 Mike Stirling
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
--
-- * Redistributions in synthesized form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of the author nor the names of other contributors may
--   be used to endorse or promote products derived from this software without
--   specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL; -- for AND_REDUCE
use IEEE.NUMERIC_STD.ALL;

entity i2c_loader is
generic (
    -- Address of slave to be loaded
    device_address : integer := 16#1a#;
    -- Number of retries to allow before stopping
    num_retries : integer := 0;
    -- Length of clock divider in bits.  Resulting bus frequency is
    -- CLK/2^(log2_divider + 2)
    log2_divider : integer := 6
);

port (
    CLK         :   in  std_logic;
    nRESET      :   in  std_logic;

    I2C_SCL     :   inout   std_logic;
    I2C_SDA     :   inout   std_logic;

    IS_DONE     :   out std_logic;
    IS_ERROR    :   out std_logic
    );
end i2c_loader;

architecture i2c_loader_arch of i2c_loader is
type regs is array(0 to 19) of std_logic_vector(7 downto 0);
constant init_regs : regs := (
    -- Left line in, 0dB, unmute
    X"00", X"17",
    -- Right line in, 0dB, unmute
    X"02", X"17",
    -- Left headphone out, 0dB
    X"04", X"79",
    -- Right headphone out, 0dB
    X"06", X"79",
    -- Audio path, DAC enabled, Line in, Bypass off, mic unmuted
    X"08", X"10",
    -- Digital path, Unmute, HP filter enabled
    X"0A", X"00",
    -- Power down mic, clkout and xtal osc
    X"0C", X"62",
    -- Format 16-bit I2S, no bit inversion or phase changes
    X"0E", X"02",
    -- Sampling control, 8 kHz USB mode (MCLK = 250fs * 6)
    X"10", X"0D",
    -- Activate
    X"12", X"01"
    );
-- Number of bursts (i.e. total number of registers)
constant burst_length : positive := 2;
-- Number of bytes to transfer per burst
constant num_bursts : positive := (init_regs'length / burst_length);

type state_t is (Idle, Start, Data, Ack, Stop, Pause, Done);
signal state : state_t;
signal phase : std_logic_vector(1 downto 0);
subtype nbit_t is integer range 0 to 7;
signal nbit : nbit_t;
subtype nbyte_t is integer range 0 to burst_length; -- +1 for address byte
signal nbyte : nbyte_t;
subtype thisbyte_t is integer range 0 to init_regs'length; -- +1 for "done"
signal thisbyte : thisbyte_t;
subtype retries_t is integer range 0 to num_retries;
signal retries : retries_t;

signal clken : std_logic;
signal divider : std_logic_vector(log2_divider-1 downto 0);
signal shiftreg : std_logic_vector(7 downto 0);
signal scl_out : std_logic;
signal sda_out : std_logic;
signal nak : std_logic;
begin
    -- Create open-drain outputs for I2C bus
    I2C_SCL <= '0' when scl_out = '0' else 'Z';
    I2C_SDA <= '0' when sda_out = '0' else 'Z';
    -- Status outputs are driven both ways
    IS_DONE <= '1' when state = Done else '0';
    IS_ERROR <= nak;

    -- Generate clock enable for desired bus speed
    clken <= AND_REDUCE(divider);
    process(nRESET,CLK)
    begin
        if nRESET = '0' then
            divider <= (others => '0');
        elsif falling_edge(CLK) then
            divider <= divider + '1';
        end if;
    end process;

    -- The I2C loader process
    process(nRESET,CLK,clken)
    begin
        if nRESET = '0' then
            scl_out <= '1';
            sda_out <= '1';
            state <= Idle;
            phase <= "00";
            nbit <= 0;
            nbyte <= 0;
            thisbyte <= 0;
            shiftreg <= (others => '0');
            nak <= '0'; -- No error
            retries <= num_retries;
        elsif rising_edge(CLK) and clken = '1' then
            -- Next phase by default
            phase <= phase + 1;

            -- STATE: IDLE
            if state = Idle then
                -- Start loading the device registers straight away
                -- A 'GO' bit could be polled here if required
                state <= Start;
                phase <= "00";
                scl_out <= '1';
                sda_out <= '1';

            -- STATE: START
            elsif state = Start then
                -- Generate START condition
                case phase is
                when "00" =>
                    -- Drop SDA first
                    sda_out <= '0';
                when "10" =>
                    -- Then drop SCL
                    scl_out <= '0';
                when "11" =>
                    -- Advance to next state
                    -- Shift register loaded with device slave address
                    state <= Data;
                    nbit <= 7;
                    shiftreg <= std_logic_vector(to_unsigned(device_address,7)) & '0'; -- writing
                    nbyte <= burst_length;
                when others =>
                    null;
                end case;

            -- STATE: DATA
            elsif state = Data then
                -- Generate data
                case phase is
                when "00" =>
                    -- Drop SCL
                    scl_out <= '0';
                when "01" =>
                    -- Output data and shift (MSb first)
                    sda_out <= shiftreg(7);
                    shiftreg <= shiftreg(6 downto 0) & '0';
                when "10" =>
                    -- Raise SCL
                    scl_out <= '1';
                when "11" =>
                    -- Next bit or advance to next state when done
                    if nbit = 0 then
                        state <= Ack;
                    else
                        nbit <= nbit - 1;
                    end if;
                when others =>
                  null;
                end case;

            -- STATE: ACK
            elsif state = Ack then
                -- Generate ACK clock and check for error condition
                case phase is
                when "00" =>
                    -- Drop SCL
                    scl_out <= '0';
                when "01" =>
                    -- Float data
                    sda_out <= '1';
                when "10" =>
                    -- Sample ack bit
                    nak <= I2C_SDA;
                    if I2C_SDA = '1' then
                        -- Error
                        nbyte <= 0; -- Close this burst and skip remaining registers
                        thisbyte <= init_regs'length;
                    else
                        -- Hold ACK to avoid spurious stops - this seems to fix a
                        -- problem with the Wolfson codec which releases the ACK
                        -- right on the falling edge of the clock pulse.  It looks like
                        -- the device interprets this is a STOP condition and then fails
                        -- to acknowledge the next byte.  We can avoid this by holding the
                        -- ACK condition for a little longer.
                        sda_out <= '0';
                    end if;
                    -- Raise SCL
                    scl_out <= '1';
                when "11" =>
                    -- Advance to next state
                    if nbyte = 0 then
                        -- No more bytes in this burst - generate a STOP
                        state <= Stop;
                    else
                        -- Generate next byte
                        state <= Data;
                        nbit <= 7;
                        shiftreg <= init_regs(thisbyte);
                        nbyte <= nbyte - 1;
                        thisbyte <= thisbyte + 1;
                    end if;
                when others =>
                    null;
                end case;

            -- STATE: STOP
            elsif state = Stop then
                -- Generate STOP condition
                case phase is
                when "00" =>
                    -- Drop SCL first
                    scl_out <= '0';
                when "01" =>
                    -- Drop SDA
                    sda_out <= '0';
                when "10" =>
                    -- Raise SCL
                    scl_out <= '1';
                when "11" =>
                    if thisbyte = init_regs'length then
                        -- All registers done, advance to finished state.  This will
                        -- bring SDA high while SCL is still high, completing the STOP
                        -- condition
                        state <= Done;
                    else
                        -- Load the next register after a short delay
                        state <= Pause;
                    end if;
                when others =>
                    null;
                end case;

            -- STATE: PAUSE
            elsif state = Pause then
                -- Delay for one cycle of 'phase' then start the next burst
                scl_out <= '1';
                sda_out <= '1';
                if phase = "11" then
                    state <= Start;
                end if;

            -- STATE: DONE
            else
                -- Finished
                scl_out <= '1';
                sda_out <= '1';

                if nak = '1' and retries > 0 then
                    -- We can retry in the event of a NAK in case the
                    -- slave got out of sync for some reason
                    retries <= retries - 1;
                    state <= Idle;
                end if;
            end if;
        end if;
    end process;
end i2c_loader_arch;

