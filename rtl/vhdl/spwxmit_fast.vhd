--
--  SpaceWire Transmitter
--
--  This entity translates outgoing characters and tokens into
--  data-strobe signalling.
--
--  The output stage is driven by a separate transmission clock "txclk" which
--  will typically be faster than the system clock. The actual transmission
--  rate is determined by dividing the transmission clock by an integer factor.
--
--  The code is tuned for implementation on Xilinx Spartan-3.
--
--  Concept
--  -------
--
--  Logic in the system clock domain generates a stream of tokens to be
--  transmitted. These tokens are encoded as instances of the token_type
--  record. Tokens are queued in a two-slot FIFO buffer (r.token0 and r.token1)
--  with a 1-bit pointer (r.tokmux) pointing to the head of the queue.
--  When a token is pushed into the buffer, a flag register is flipped
--  (r.sysflip0 and r.sysflip1) to indicate to the txclk domain that the
--  buffer slot has been refilled.
--
--  The txclk domain pulls tokens from the FIFO buffer, flipping flag
--  registers (rtx.txflip0 and rtx.txflip1) to indicate to the system clock
--  domain that a token has been pulled. When the system clock domain detects
--  that a token has been consumed, it refills the buffer slot with a new
--  token (assuming that there are tokens waiting to be transmitted).
--  Whenever the FIFO buffer is empty, the txclk domain sends NULLs instead.
--  This can happen either when there are no tokens to send, or when the
--  system clock domain is late to refill the buffer.
--
--  Details
--  -------
--
--  Logic in the system clock domain accepts transmission requests through
--  the external interface of the entity. Pending requests are translated
--  into a stream of tokens. The tokens are pushed to the txclk domain through
--  the FIFO buffer as described above.
--
--  The data path through the txclk domain is divided into stages B through F
--  in a half-hearted attempt to keep things simple.
--
--  Stage B takes a token from the FIFO buffer and updates a buffer status
--  flag to indicate that the buffer slot needs to be refilled. If the FIFO
--  is empty, a NULL is inserted. Stage B is triggered one clock after
--  stage E switches to a new token. If the previous token was ESC, stage B
--  skips a turn because stage C will already know what to do.
--
--  Stage C takes a token from stage B and translates it into a bit pattern.
--  Time codes and NULL tokens are broken into two separate tokens starting
--  with ESC. Stage C is triggered one clock after the shift buffer in
--  stage E drops to 3 tokens.
--
--  Stage D completes the task of translating tokens to bit patterns and
--  distinguishes between 10-bit and 4-bit tokens. It is not explicitly
--  triggered but simply follows stage C.
--
--  Stage E is the bit shift register. It shifts when "txclken" is high.
--  A one-hot counter keeps track of the number of bits remaining in
--  the register. When the register falls empty, it loads a new 10-bit or
--  4-bit pattern as prepared by stage D. Stage E also computes parity.
--
--  Stage F performs data strobe encoding. When the transmitter is disabled,
--  the outputs of stage F fall to zero in a controlled way.
-- 
--  To generate the transmission bit clock, the txclk is divided by an
--  integer factor (divcnt+1) using an 8-bit down counter. The implementation
--  of this counter has become quite complicated in order to meet timing goals.
--  The counter consists of 4 blocks of two bits each (txclkcnt), with a
--  carry-save concept used between blocks (txclkcy). Detection of terminal
--  count (txclkdone) has a pipeline delay of two cycles. Therefore a separate
--  concept is used if the initial count is less than 2 (txdivnorm). This is
--  all glued together in the final assignment to txclken.
--
--  The initial count for txclk division (divcnt) comes from the system clock
--  domain and thus needs to be synchronized for use in the txclk domain.
--  To facilitate this, the system clock domain latches the value of divcnt
--  once every 6 sysclk cycles and sets a flag to indicate when the latched
--  value can safely be used by the txclk domain.
--
--  A tricky aspect of the design is the initial state of the txclk logic.
--  When the transmitter is enabled (txen goes high), the txclk logic starts
--  with the first ESC pattern already set up in stage D, and stage C ready
--  to produce the FCT part of the first NULL.
--
--  The following guidelines are used to get good timing for the txclk domain:
--   * The new value of a register depends on at most 4 inputs (single LUT),
--     or in a few cases on 5 inputs (two LUTs and F5MUX).
--   * Synchronous resets may be used, but only if the reset signal comes
--     directly from a register (no logic in set/reset path);
--   * Clock enables may be used, but only if the enable signal comes directly
--     from a register (no logic in clock enable path).
--
--  Synchronization issues
--  ----------------------
--
--  There is a two-slot FIFO buffer between the system and txclk domains.
--  After the txclk domain pulls a token from the buffer, the system clock
--  domain should ideally refill the buffer before the txclk domain again
--  tries to pull from the same buffer slot. If the refill occurs late,
--  the txclk domain needs to insert a NULL token which is inefficient
--  use of bandwidth.
--
--  Assuming the transmission consists of a stream of data characters,
--  10 bits per character, there are exactly 2*10 bit periods between
--  successive reads from the same buffer slot by the txclk logic.
--
--  The time needed for the system clock logic to refill a buffer slot =
--     1 txclk period   (update of rtx.txflipN)
--   + 1 txclk period   (routing delay between domains)
--   + 2 sysclk periods (synchronizer for txflipN)
--   + 1 sysclk period  (refill buffer slot and update r.sysflipN)
--   + 1 txclk period   (routing delay between domains)
--   + 2 txclk periods  (synchronizer for sysflipN)
--   = 5 txclk periods + 3 sysclk periods
--
--  If for example txclk is 4 times as fast as sysclk, this amounts to
--   5 txclk + 3 sysclk = 5 + 3*4 txclk = 17 txclk
--  is less than 20 bit periods even at maximum transmission rate, so
--  no problem there.
--
--  This is different when the data stream includes 4-bit tokens.
--  See the manual for further comments.
--
--  Implementation guidelines
--  -------------------------
--
--  To minimize clock skew, IOB flip-flops should be used to drive
--  spw_do and spw_so.
--
--  "txclk" must be at least as fast as the system clock;
--  "txclk" does not need to be phase-related to the system clock;
--  it is allowed for "txclk" to be equal to "clk".
--
--  The following timing constraints are needed:
--   * PERIOD constraint on the system clock;
--   * PERIOD constraint on "txclk";
--   * FROM-TO constraint from "txclk" to the system clock, equal to
--     one "txclk" period;
--   * FROM-TO constraint from the system clock to "txclk", equal to
--     one "txclk" period.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spwpkg.all;

entity spwxmit_fast is

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Transmit clock.
        txclk:      in  std_logic;

        -- Synchronous reset (active-high)
        -- Used asynchronously by fast clock domain (must be glitch-free).
        rst:        in  std_logic;

        -- Scaling factor minus 1, used to scale the system clock into the
        -- transmission bit rate. The system clock is divided by
        -- (unsigned(divcnt) + 1). Changing this signal will immediately
        -- change the transmission rate.
        divcnt:     in  std_logic_vector(7 downto 0);

        -- Input signals from spwlink.
        xmiti:      in  spw_xmit_in_type;

        -- Output signals to spwlink.
        xmito:      out spw_xmit_out_type;

        -- Data Out signal to SpaceWire bus.
        spw_do:     out std_logic;

        -- Strobe Out signal to SpaceWire bus.
        spw_so:     out std_logic
    );

    -- Turn off FSM extraction to avoid synchronization problems.
    attribute FSM_EXTRACT: string;
    attribute FSM_EXTRACT of spwxmit_fast: entity is "NO";

end entity spwxmit_fast;

architecture spwxmit_fast_arch of spwxmit_fast is

    -- Convert boolean to std_logic.
    type bool_to_logic_type is array(boolean) of std_ulogic;
    constant bool_to_logic: bool_to_logic_type := (false => '0', true => '1');

    -- Data records passed between clock domains.
    type token_type is record
        tick:       std_ulogic;                     -- send time code
        fct:        std_ulogic;                     -- send FCT
        fctpiggy:   std_ulogic;                     -- send FCT and N-char
        flag:       std_ulogic;                     -- send EOP or EEP
        char:       std_logic_vector(7 downto 0);   -- character or time code
    end record;

    -- Registers in txclk domain
    type txregs_type is record
        -- sync to system clock domain
        txflip0:    std_ulogic;
        txflip1:    std_ulogic;
        -- stage B
        b_update:   std_ulogic;
        b_mux:      std_ulogic;
        b_txflip:   std_ulogic;
        b_valid:    std_ulogic;
        b_token:    token_type;
        -- stage C
        c_update:   std_ulogic;
        c_busy:     std_ulogic;
        c_esc:      std_ulogic;
        c_fct:      std_ulogic;
        c_bits:     std_logic_vector(8 downto 0);
        -- stage D
        d_bits:     std_logic_vector(8 downto 0);
        d_cnt4:     std_ulogic;
        d_cnt10:    std_ulogic;
        -- stage E
        e_valid:    std_ulogic;
        e_shift:    std_logic_vector(9 downto 0);
        e_count:    std_logic_vector(9 downto 0);
        e_parity:   std_ulogic;
        -- stage F
        f_spwdo:    std_ulogic;
        f_spwso:    std_ulogic;
        -- tx clock enable logic
        txclken:    std_ulogic;
        txclkpre:   std_ulogic;
        txclkcnt:   std_logic_vector(7 downto 0);
        txclkcy:    std_logic_vector(2 downto 0);
        txclkdone:  std_logic_vector(1 downto 0);
        txclkdiv:   std_logic_vector(7 downto 0);
        txdivnorm:  std_ulogic;
    end record;

    -- Registers in system clock domain
    type regs_type is record
        -- sync status to txclk domain
        txenreg:    std_ulogic;
        txdivreg:   std_logic_vector(7 downto 0);
        txdivnorm:  std_ulogic;
        txdivtmp:   std_logic_vector(1 downto 0);
        txdivsafe:  std_ulogic;
        -- data stream to txclk domain
        sysflip0:   std_ulogic;
        sysflip1:   std_ulogic;
        token0:     token_type;
        token1:     token_type;
        tokmux:     std_ulogic;
        -- transmitter management
        pend_fct:   std_ulogic;                     -- '1' if an outgoing FCT is pending
        pend_char:  std_ulogic;                     -- '1' if an outgoing N-Char is pending
        pend_data:  std_logic_vector(8 downto 0);   -- control flag and data bits of pending char
        pend_tick:  std_ulogic;                     -- '1' if an outgoing time tick is pending
        pend_time:  std_logic_vector(7 downto 0);   -- data bits of pending time tick
        allow_fct:  std_ulogic;                     -- '1' when allowed to send FCTs
        allow_char: std_ulogic;                     -- '1' when allowed to send data and time
        sent_fct:   std_ulogic;                     -- '1' when at least one FCT token was sent
    end record;

    -- Initial state of system clock domain
    constant token_reset: token_type := (
        tick        => '0',
        fct         => '0',
        fctpiggy    => '0',
        flag        => '0',
        char        => (others => '0') );
    constant regs_reset: regs_type := (
        txenreg     => '0',
        txdivreg    => (others => '0'),
        txdivnorm   => '0',
        txdivtmp    => "00",
        txdivsafe   => '0',
        sysflip0    => '0',
        sysflip1    => '0',
        token0      => token_reset,
        token1      => token_reset,
        tokmux      => '0',
        pend_fct    => '0',
        pend_char   => '0',
        pend_data   => (others => '0'),
        pend_tick   => '0',
        pend_time   => (others => '0'),
        allow_fct   => '0',
        allow_char  => '0',
        sent_fct    => '0' );

    -- Signals that are re-synchronized from system clock to txclk domain.
    type synctx_type is record
        rstn:       std_ulogic;
        sysflip0:   std_ulogic;
        sysflip1:   std_ulogic;
        txen:       std_ulogic;
        txdivsafe:  std_ulogic;
    end record;

    -- Signals that are re-synchronized from txclk to system clock domain.
    type syncsys_type is record
        txflip0:    std_ulogic;
        txflip1:    std_ulogic;
    end record;

    -- Registers
    signal rtx:     txregs_type;
    signal rtxin:   txregs_type;
    signal r:       regs_type := regs_reset;
    signal rin:     regs_type;

    -- Synchronized signals after crossing clock domains.
    signal synctx:  synctx_type;
    signal syncsys: syncsys_type;

    -- Output flip-flops
    signal s_spwdo: std_logic;
    signal s_spwso: std_logic;

    -- Force use of IOB flip-flops
    attribute IOB: string;
    attribute IOB of s_spwdo: signal is "TRUE";
    attribute IOB of s_spwso: signal is "TRUE";

begin

    -- Reset synchronizer for txclk domain.
    synctx_rst: syncdff
        port map ( clk => txclk, rst => rst, di => '1',         do => synctx.rstn );

    -- Synchronize signals from system clock domain to txclk domain.
    synctx_sysflip0: syncdff
        port map ( clk => txclk, rst => rst, di => r.sysflip0,  do => synctx.sysflip0 );
    synctx_sysflip1: syncdff
        port map ( clk => txclk, rst => rst, di => r.sysflip1,  do => synctx.sysflip1 );
    synctx_txen: syncdff
        port map ( clk => txclk, rst => rst, di => r.txenreg,   do => synctx.txen );
    synctx_txdivsafe: syncdff
        port map ( clk => txclk, rst => rst, di => r.txdivsafe, do => synctx.txdivsafe );

    -- Synchronize signals from txclk domain to system clock domain.
    syncsys_txflip0: syncdff
        port map ( clk => clk,   rst => rst, di => rtx.txflip0, do => syncsys.txflip0 );
    syncsys_txflip1: syncdff
        port map ( clk => clk,   rst => rst, di => rtx.txflip1, do => syncsys.txflip1 );

    -- Drive SpaceWire output signals
    spw_do      <= s_spwdo;
    spw_so      <= s_spwso;

    -- Combinatorial process
    process (r, rtx, rst, divcnt, xmiti, synctx, syncsys) is
        variable v:         regs_type;
        variable vtx:       txregs_type;
        variable v_needtoken: std_ulogic;
        variable v_havetoken: std_ulogic;
        variable v_token:     token_type;
    begin
        v           := r;
        vtx         := rtx;
        v_needtoken := '0';
        v_havetoken := '0';
        v_token     := token_reset;

        -- ---- FAST CLOCK DOMAIN ----

        -- Stage B: Multiplex tokens from system clock domain.
        -- Update stage B three bit periods after updating stage C
        -- (i.e. in time for the next update of stage C).
        -- Do not update stage B if stage C is indicating that it needs to
        -- send a second token to complete its task.
        vtx.b_update := rtx.txclken and rtx.e_count(0) and (not rtx.c_busy);
        if rtx.b_mux = '0' then
            vtx.b_txflip := rtx.txflip0;
        else
            vtx.b_txflip := rtx.txflip1;
        end if;
        if rtx.b_update = '1' then
            if rtx.b_mux = '0' then
                -- get token from slot 0
                vtx.b_valid := synctx.sysflip0 xor rtx.b_txflip;
                vtx.b_token := r.token0;
                -- update mux flag if we got a valid token
                vtx.b_mux   := synctx.sysflip0 xor rtx.b_txflip;
                vtx.txflip0 := synctx.sysflip0;
                vtx.txflip1 := rtx.txflip1;
            else
                -- get token from slot 1
                vtx.b_valid := synctx.sysflip1 xor rtx.b_txflip;
                vtx.b_token := r.token1;
                -- update mux flag if we got a valid token
                vtx.b_mux   := not (synctx.sysflip1 xor rtx.b_txflip);
                vtx.txflip0 := rtx.txflip0;
                vtx.txflip1 := synctx.sysflip1;
            end if;
        end if;

        -- Stage C: Prepare to transmit EOP, EEP or a data character.
        vtx.c_update := rtx.txclken and rtx.e_count(3);
        if rtx.c_update = '1' then

            -- NULL is broken into two tokens: ESC + FCT.
            -- Time-codes are broken into two tokens: ESC + char.

            -- Enable c_esc on the first pass of a NULL or a time-code.
            vtx.c_esc   := (rtx.b_token.tick or (not rtx.b_valid)) and
                           (not rtx.c_esc);

            -- Enable c_fct on the first pass of an FCT and on
            -- the second pass of a NULL (also the first pass, but c_esc
            -- is stronger than c_fct).
            vtx.c_fct   := (rtx.b_token.fct and (not rtx.c_busy)) or
                           (not rtx.b_valid);

            -- Enable c_busy on the first pass of a NULL or a time-code
            -- or a piggy-backed FCT. This will tell stage B that we are
            -- not done yet.
            vtx.c_busy  := (rtx.b_token.tick or (not rtx.b_valid) or
                            rtx.b_token.fctpiggy) and (not rtx.c_busy);

            if rtx.b_token.flag = '1' then
                if rtx.b_token.char(0) = '0' then
                    -- prepare to send EOP
                    vtx.c_bits  := "000000101"; -- EOP = P101
                else
                    -- prepare to send EEP
                    vtx.c_bits  := "000000011"; -- EEP = P110
                end if;
            else
                -- prepare to send data char
                vtx.c_bits  := rtx.b_token.char & '0';
            end if;
        end if;

        -- Stage D: Prepare to transmit FCT, ESC, or the stuff from stage C.
        if rtx.c_esc = '1' then
            -- prepare to send ESC
            vtx.d_bits  := "000000111";     -- ESC = P111
            vtx.d_cnt4  := '1';             -- 3 bits + implicit parity bit
            vtx.d_cnt10 := '0';
        elsif rtx.c_fct = '1' then
            -- prepare to send FCT
            vtx.d_bits  := "000000001";     -- FCT = P100
            vtx.d_cnt4  := '1';             -- 3 bits + implicit parity bit
            vtx.d_cnt10 := '0';
        else
            -- send the stuff from stage C.
            vtx.d_bits  := rtx.c_bits;
            vtx.d_cnt4  := rtx.c_bits(0);
            vtx.d_cnt10 := not rtx.c_bits(0);
        end if;

        -- Stage E: Shift register.
        if rtx.txclken = '1' then
            if rtx.e_count(0) = '1' then
                -- reload shift register; output parity bit
                vtx.e_valid  := '1';
                vtx.e_shift(vtx.e_shift'high downto 1) := rtx.d_bits;
                vtx.e_shift(0) := not (rtx.e_parity xor rtx.d_bits(0));
                vtx.e_count  := rtx.d_cnt10 & "00000" & rtx.d_cnt4 & "000";
                vtx.e_parity := rtx.d_bits(0);
            else
                -- shift bits to output; update parity bit
                vtx.e_shift  := '0' & rtx.e_shift(rtx.e_shift'high downto 1);
                vtx.e_count  := '0' & rtx.e_count(rtx.e_count'high downto 1);
                vtx.e_parity := rtx.e_parity xor rtx.e_shift(1);
            end if;
        end if;

        -- Stage F: Data/strobe encoding.
        if rtx.txclken = '1' then
            if rtx.e_valid = '1' then
                -- output next data/strobe bits
                vtx.f_spwdo := rtx.e_shift(0);
                vtx.f_spwso := not (rtx.e_shift(0) xor rtx.f_spwdo xor rtx.f_spwso);
            else
                -- gentle reset of spacewire signals
                vtx.f_spwdo := rtx.f_spwdo and rtx.f_spwso;
                vtx.f_spwso := '0';
            end if;
        end if;

        -- Generate tx clock enable
        -- An 8-bit counter decrements on every clock. A txclken pulse is
        -- produced 2 cycles after the counter reaches value 2. Counter reload
        -- values of 0 and 1 are handled as special cases.
        -- count down in blocks of two bits
        vtx.txclkcnt(1 downto 0) := std_logic_vector(unsigned(rtx.txclkcnt(1 downto 0)) - 1);
        vtx.txclkcnt(3 downto 2) := std_logic_vector(unsigned(rtx.txclkcnt(3 downto 2)) - unsigned(rtx.txclkcy(0 downto 0)));
        vtx.txclkcnt(5 downto 4) := std_logic_vector(unsigned(rtx.txclkcnt(5 downto 4)) - unsigned(rtx.txclkcy(1 downto 1)));
        vtx.txclkcnt(7 downto 6) := std_logic_vector(unsigned(rtx.txclkcnt(7 downto 6)) - unsigned(rtx.txclkcy(2 downto 2)));
        -- propagate carry in blocks of two bits
        vtx.txclkcy(0) := bool_to_logic(rtx.txclkcnt(1 downto 0) = "00");
        vtx.txclkcy(1) := rtx.txclkcy(0) and bool_to_logic(rtx.txclkcnt(3 downto 2) = "00");
        vtx.txclkcy(2) := rtx.txclkcy(1) and bool_to_logic(rtx.txclkcnt(5 downto 4) = "00");
        -- detect value 2 in counter
        vtx.txclkdone(0) := bool_to_logic(rtx.txclkcnt(3 downto 0) = "0010");
        vtx.txclkdone(1) := bool_to_logic(rtx.txclkcnt(7 downto 4) = "0000");
        -- trigger txclken
        vtx.txclken  := (rtx.txclkdone(0) and rtx.txclkdone(1)) or rtx.txclkpre;
        vtx.txclkpre := (not rtx.txdivnorm) and ((not rtx.txclkpre) or (not rtx.txclkdiv(0)));
        -- reload counter
        if rtx.txclken = '1' then
            vtx.txclkcnt  := rtx.txclkdiv;
            vtx.txclkcy   := "000";
            vtx.txclkdone := "00";
        end if;

        -- Synchronize txclkdiv
        if synctx.txdivsafe = '1' then
            vtx.txclkdiv  := r.txdivreg;
            vtx.txdivnorm := r.txdivnorm;
        end if;

        -- Transmitter disabled.
        if synctx.txen = '0' then
            vtx.txflip0   := '0';
            vtx.txflip1   := '0';
            vtx.b_update  := '0';
            vtx.b_mux     := '0';
            vtx.b_valid   := '0';
            vtx.c_update  := '0';
            vtx.c_busy    := '1';
            vtx.c_esc     := '1';           -- need to send 2nd part of NULL
            vtx.c_fct     := '1';
            vtx.d_bits    := "000000111";   -- ESC = P111
            vtx.d_cnt4    := '1';           -- 3 bits + implicit parity bit
            vtx.d_cnt10   := '0';
            vtx.e_valid   := '0';
            vtx.e_parity  := '0';
            vtx.e_count   := (0 => '1', others => '0');
        end if;

        -- Reset.
        if synctx.rstn = '0' then
            vtx.f_spwdo   := '0';
            vtx.f_spwso   := '0';
            vtx.txclken   := '0';
            vtx.txclkpre  := '1';
            vtx.txclkcnt  := (others => '0');
            vtx.txclkdiv  := (others => '0');
            vtx.txdivnorm := '0';
        end if;

        -- ---- SYSTEM CLOCK DOMAIN ----

        -- Hold divcnt and txen for use by txclk domain.
        v.txdivtmp  := std_logic_vector(unsigned(r.txdivtmp) - 1);
        if r.txdivtmp = "00" then
            if r.txdivsafe = '0' then
                -- Latch the current value of divcnt and txen.
                v.txdivsafe := '1';
                v.txdivtmp  := "01";
                v.txdivreg  := divcnt;
                if unsigned(divcnt(divcnt'high downto 1)) = 0 then
                    v.txdivnorm := '0';
                else
                    v.txdivnorm := '1';
                end if;
                v.txenreg   := xmiti.txen;
            else
                -- Drop the txdivsafe flag but keep latched values.
                v.txdivsafe := '0';
            end if;
        end if;

        -- Pass falling edge of txen signal as soon as possible.
        if xmiti.txen = '0' then
            v.txenreg   := '0';
        end if;

        -- Store requests for FCT transmission.
        if xmiti.fct_in = '1' and r.allow_fct = '1' then
            v.pend_fct  := '1';
        end if;

        if xmiti.txen = '0' then

            -- Transmitter disabled; reset state.
            v.sysflip0    := '0';
            v.sysflip1    := '0';
            v.tokmux      := '0';
            v.pend_fct    := '0';
            v.pend_char   := '0';
            v.pend_tick   := '0';
            v.allow_fct   := '0';
            v.allow_char  := '0';
            v.sent_fct    := '0';

        else

            -- Determine if a new token is needed.
            if r.tokmux = '0' then
                if r.sysflip0 = syncsys.txflip0 then
                    v_needtoken := '1';
                end if;
            else
                if r.sysflip1 = syncsys.txflip1 then
                    v_needtoken := '1';
                end if;
            end if;

            -- Prepare new token.
            if r.allow_char = '1' and r.pend_tick = '1' then
                -- prepare to send time code
                v_token.tick  := '1';
                v_token.fct   := '0';
                v_token.fctpiggy := '0';
                v_token.flag  := '0';
                v_token.char  := r.pend_time;
                v_havetoken   := '1';
                if v_needtoken = '1' then
                    v.pend_tick := '0';
                end if;
            else
                if r.allow_fct = '1' and (xmiti.fct_in = '1' or r.pend_fct = '1') then
                    -- prepare to send FCT
                    v_token.fct   := '1';
                    v_havetoken   := '1';
                    if v_needtoken = '1' then
                        v.pend_fct  := '0';
                        v.sent_fct  := '1';
                    end if;
                end if;
                if r.allow_char = '1' and r.pend_char = '1' then
                    -- prepare to send N-Char
                    -- Note: it is possible to send an FCT and an N-Char
                    -- together by enabling the fctpiggy flag.
                    v_token.fctpiggy := v_token.fct;
                    v_token.flag  := r.pend_data(8);
                    v_token.char  := r.pend_data(7 downto 0);
                    v_havetoken   := '1';
                    if v_needtoken = '1' then
                        v.pend_char := '0';
                    end if;
                end if;
            end if;

            -- Put new token in slot.
            if v_havetoken = '1' then
                if r.tokmux = '0' then
                    if r.sysflip0 = syncsys.txflip0 then
                        v.sysflip0  := not r.sysflip0;
                        v.token0    := v_token;
                        v.tokmux    := '1';
                    end if;
                else
                    if r.sysflip1 = syncsys.txflip1 then
                        v.sysflip1  := not r.sysflip1;
                        v.token1    := v_token;
                        v.tokmux    := '0';
                    end if;
                end if;
            end if;

            -- Determine whether we are allowed to send FCTs and characters
            v.allow_fct  := not xmiti.stnull;
            v.allow_char := (not xmiti.stnull) and (not xmiti.stfct) and r.sent_fct;

            -- Store request for data transmission.
            if xmiti.txwrite = '1' and r.allow_char = '1' and r.pend_char = '0' then
                v.pend_char  := '1';
                v.pend_data  := xmiti.txflag & xmiti.txdata;
            end if;

            -- Store requests for time tick transmission.
            if xmiti.tick_in = '1' then
                v.pend_tick := '1';
                v.pend_time := xmiti.ctrl_in & xmiti.time_in;
            end if;

        end if;

        -- Synchronous reset of system clock domain.
        if rst = '1' then
            v := regs_reset;
        end if;

        -- Drive outputs.
        -- Note: the outputs are combinatorially dependent on certain inputs.

        -- Set fctack high if (FCT requested) and (FCTs allowed) AND
        -- (no FCT pending)
        xmito.fctack <= xmiti.fct_in and xmiti.txen and r.allow_fct and
                        (not r.pend_fct);

        -- Set txrdy high if (character requested) AND (characters allowed) AND
        -- (no character pending)
        xmito.txack <= xmiti.txwrite and xmiti.txen and r.allow_char and
                       (not r.pend_char);

        -- Update registers.
        rin     <= v;
        rtxin   <= vtx;
    end process;

    -- Synchronous process in txclk domain
    process (txclk) is
    begin
        if rising_edge(txclk) then
            -- drive spacewire output signals
            s_spwdo <= rtx.f_spwdo;
            s_spwso <= rtx.f_spwso;
            -- update registers
            rtx <= rtxin;
        end if;
    end process;

    -- Synchronous process in system clock domain
    process (clk) is
    begin
        if rising_edge(clk) then
            -- update registers
            r <= rin;
        end if;
    end process;

end architecture spwxmit_fast_arch;
