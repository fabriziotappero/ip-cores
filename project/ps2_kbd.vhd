--
-- This circuit accepts a serial datastream and clock from a PS/2 keyboard
-- and outputs the scancode for any key that is pressed.
--
-- Notes:
--   
--   1. The clock from the PS/2 keyboard does not drive the clock inputs of
--      any of the registers in this circuit.  Instead, it is sampled at the
--      frequency of the main clock input and edges are extracted from the samples.
--      So you have to apply a main clock that is substantially faster than
--      the 10 KHz PS/2 clock.  It should be 200 KHz or more.
--
--   2. The scancode is only valid when the ready signal is high.  The scancode
--      should be registered by an external circuit on the first clock edge
--      after the ready signal goes high.
--
--   3. The ready signal pulses only after the key is released.
--
--   4. The error flag is set whenever the PS/2 clock stops pulsing and the
--      PS/2 clock is either at a low level or less than 11 bits of serial
--      data have been received (start + 8 data + parity + stop).  The circuit
--      locks up once an error is detected and will not resume operation until
--      a reset is applied.
--



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package ps2_kbd_pckg is
  component ps2_kbd
    generic(
      FREQ     :     natural := 50_000  -- frequency of the main clock (KHz)
      );
    port(
      clk      : in  std_logic;         -- main clock
      rst      : in  std_logic;         -- asynchronous reset
      ps2_clk  : in  std_logic;         -- clock from keyboard
      ps2_data : in  std_logic;         -- data from keyboard
      scancode : out std_logic_vector(7 downto 0);  -- key scancode
      parity   : out std_logic;         -- parity bit for scancode
      busy     : out std_logic;         -- busy receiving scancode
      rdy      : out std_logic;         -- scancode ready pulse
      error    : out std_logic          -- error receiving scancode
      );
  end component ps2_kbd;
end package ps2_kbd_pckg;



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ps2_kbd is
  generic(
    FREQ     :     natural := 50_000   -- frequency of the main clock (KHz)
    );
  port(
    clk      : in  std_logic;           -- main clock
    rst      : in  std_logic;           -- asynchronous reset
    ps2_clk  : in  std_logic;           -- clock from keyboard
    ps2_data : in  std_logic;           -- data from keyboard
    scancode : out std_logic_vector(7 downto 0);  -- key scancode
    parity   : out std_logic;           -- parity bit for scancode
    busy     : out std_logic;           -- busy receiving scancode
    rdy      : out std_logic;           -- scancode ready pulse
    error    : out std_logic            -- error receiving scancode
    );
end entity ps2_kbd;


architecture arch of ps2_kbd is

  constant YES         : std_logic                    := '1';
  constant NO          : std_logic                    := '0';
  constant PS2_FREQ    : natural                      := 10;  -- keyboard clock frequency (KHz)
  constant TIMEOUT     : natural                      := FREQ / PS2_FREQ;  -- ps2_clk quiet timeout
  constant KEY_RELEASE : std_logic_vector(7 downto 0) := "11110000";  -- scancode sent when key is released

  signal timer_x, timer_r     : natural range 0 to TIMEOUT;  -- counts time since last PS/2 clock edge
  signal bitcnt_x, bitcnt_r   : natural range 0 to 11;  -- counts number of received scancode bits
  signal ps2_clk_x, ps2_clk_r : std_logic_vector(5 downto 1);  -- PS/2 clock synchronization / edge detect shift register
  signal ps2_clk_fall_edge    : std_logic;  -- pulses on falling edge of PS/2 clock
  signal ps2_clk_rise_edge    : std_logic;  -- pulses on rising edge of PS/2 clock
  signal ps2_clk_edge         : std_logic;  -- pulses on either edge of PS/2 clock
  signal ps2_clk_quiet        : std_logic;  -- pulses when no edges on PS/2 clock for TIMEOUT
  signal sc_x, sc_r           : std_logic_vector(9 downto 0);  -- scancode shift register
  signal keyrel_x, keyrel_r   : std_logic;  -- this flag is set when the key release scancode is received
  signal scancode_rdy         : std_logic;  -- indicates when any scancode has been received
  signal rdy_x, rdy_r         : std_logic;  -- this flag is set when scancode for the pressed key is ready
  signal error_x, error_r     : std_logic;  -- this flag is set when an error occurs

begin

  -- shift the level on the PS/2 clock into a shift register
  ps2_clk_x <= ps2_clk_r(4 downto 1) & ps2_clk;

  -- look at the PS/2 clock levels stored in the shift register and find rising or falling edges
  ps2_clk_fall_edge <= YES when ps2_clk_r(5 downto 2) = "1100" else NO;
  ps2_clk_rise_edge <= YES when ps2_clk_r(5 downto 2) = "0011" else NO;
  ps2_clk_edge      <= ps2_clk_fall_edge or ps2_clk_rise_edge;

  -- shift the keyboard scancode into the shift register on the falling edge of the PS/2 clock
  sc_x <= ps2_data & sc_r(9 downto 1) when ps2_clk_fall_edge = YES else sc_r;

  -- clear the timer right after a PS/2 clock edge and then keep incrementing it until the next edge
  timer_x <= 0 when ps2_clk_edge = YES else timer_r + 1;

  -- indicate when the PS/2 clock has stopped pulsing and is at a high level.
  ps2_clk_quiet <= YES when timer_r = TIMEOUT and ps2_clk_r(2) = '1' else NO;

  -- increment the bit counter on each falling edge of the PS/2 clock.
  -- reset the bit counter if the PS/2 clock stops pulsing or if there was an error receiving the scancode.
  -- otherwise, keep the bit counter unchanged.
  bitcnt_x <= bitcnt_r + 1 when ps2_clk_fall_edge = YES              else
              0            when ps2_clk_quiet = YES or error_r = YES else
              bitcnt_r;

  -- a scancode has been received if the bit counter is 11 and the PS/2 clock has stopped pulsing
  scancode_rdy <= YES when bitcnt_r = 11 and ps2_clk_quiet = YES else NO;

  -- look for the scancode sent when the key is released
  keyrel_x <= YES when sc_r(scancode'range) = KEY_RELEASE and scancode_rdy = YES else
              NO  when rdy_r = YES or error_r = YES                              else
              keyrel_r;

  -- the scancode for the pressed key arrives after receiving the key-release scancode 
  -- Changed: removed key release requirement, send all keys up.
  -- rdy_x <= YES when keyrel_r = YES and scancode_rdy = YES else NO;
  rdy_x <= YES when scancode_rdy = YES else NO;

  -- indicate an error if the clock is low for too long or if it stops pulsing in the middle of a scancode
  error_x <= YES when (timer_r = TIMEOUT and ps2_clk_r(2) = '0') or
             (ps2_clk_quiet = YES and bitcnt_r/=11 and bitcnt_r/=0) else
             error_r;

  scancode <= sc_r(scancode'range);     -- output scancode
  parity   <= sc_r(scancode'high+1);    -- output parity bit for the scancode
  busy     <= YES when bitcnt_r/=0 else NO;  -- output busy signal when receiving a scancode
  rdy      <= rdy_r;                    -- output scancode ready flag
  error    <= error_r;                  -- output error flag

  -- update the various registers
  process(rst, clk)
  begin
    if rst = YES then
      ps2_clk_r <= (others => '1');     -- start by assuming PS/2 clock has been high for a while
      sc_r      <= (others => '0');     -- clear scancode register
      keyrel_r  <= NO;                  -- key-release scancode has not been received yet
      rdy_r     <= NO;                  -- no scancodes received yet
      timer_r   <= 0;                   -- clear PS/2 clock pulse timer
      bitcnt_r  <= 0;                   -- clear scancode bit counter
      error_r   <= NO;                  -- clear any errors
    elsif rising_edge(clk) then
      ps2_clk_r <= ps2_clk_x;
      sc_r      <= sc_x;
      keyrel_r  <= keyrel_x;
      rdy_r     <= rdy_x;
      timer_r   <= timer_x;
      bitcnt_r  <= bitcnt_x;
      error_r   <= error_x;
    end if;
  end process;

end architecture arch;
