--
--  Front-end for SpaceWire Receiver
--
--  This entity samples the input signals DataIn and StrobeIn to detect
--  valid bit transitions. Received bits are handed to the application
--  in groups of "rxchunk" bits at a time, synchronous to the system clock.
--
--  This receiver is based on synchronous oversampling of the input signals.
--  Inputs are sampled on the rising and falling edges of an externally
--  supplied sample clock "rxclk". Therefore the maximum bitrate of the
--  incoming signal must be significantly lower than two times the "rxclk"
--  clock frequency. The maximum incoming bitrate must also be strictly
--  lower than rxchunk times the system clock frequency.
--
--  This code is tuned for implementation on Xilinx Spartan-3.
--
--  Details
--  -------
--
--  Stage A: The inputs "spw_di" and "spw_si" are handled as DDR signals,
--  synchronously sampled on both edges of "rxclk".
--
--  Stage B: The input signals are re-registered on the rising edge of "rxclk"
--  for further processing. This implies that every rising edge of "rxclk"
--  produces two new samples of "spw_di" and two new samples of "spw_si".
--
--  Stage C: Transitions in input signals are detected by comparing the XOR
--  of data and strobe to the XOR of the previous data and strobe samples.
--  If there is a difference, we know that either data or strobe has changed
--  and the new value of data is a valid new bit. Every rising edge of "rxclk"
--  thus produces either zero, or one or two new data bits.
--
--  Stage D: Received bits are collected in groups of "rxchunk" bits
--  (unless rxchunk=1, in which case groups of 2 bits are used). Complete
--  groups are pushed into an 8-deep cyclic buffer. A 3-bit counter "headptr"
--  indicates the current position in the cyclic buffer.
--
--  The system clock domain reads bit groups from the cyclic buffer. A tail
--  pointer indicates the next location to read from the buffer. A comparison
--  between the "tailptr" and a re-synchronized copy of the "headptr" determines
--  whether valid bits are available in the buffer.
--
--  Activity detection is based on a 3-bit counter "bitcnt". This counter is
--  incremented whenever the rxclk domain receives 1 or 2 new bits. The system
--  clock domain monitors a re-synchronized copy of the activity counter to
--  determine whether it has been updated since the previous system clock cycle.
--
--  Implementation guidelines 
--  -------------------------
--
--  IOB flip-flops must be used to sample spw_di and spw_si.
--  Clock skew between the IOBs for spw_di and spw_si must be minimized.
--
--  "rxclk" must be at least as fast as the system clock;
--  "rxclk" does not need to be phase-related to the system clock;
--  it is allowed for "rxclk" to be equal to the system clock.
--
--  The following timing constraints are needed:
--   * PERIOD constraint on the system clock;
--   * PERIOD constraint on "rxclk";
--   * FROM-TO constraint from "rxclk" to system clock, equal to one "rxclk" period;
--   * FROM-TO constraint from system clock to "rxclk", equal to one "rxclk" period.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spwpkg.all;

entity spwrecvfront_fast is

    generic (
        -- Number of bits to pass to the application per system clock.
        rxchunk:        integer range 1 to 4 );

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Sample clock.
        rxclk:      in  std_logic;

        -- High to enable receiver; low to disable and reset receiver.
        rxen:       in  std_logic;

        -- High if there has been recent activity on the input lines.
        inact:      out std_logic;

        -- High if inbits contains a valid group of received bits.
        -- If inbvalid='1', the application must sample inbits on
        -- the rising edge of clk.
        inbvalid:   out std_logic;

        -- Received bits (bit 0 is the earliest received bit).
        inbits:     out std_logic_vector(rxchunk-1 downto 0);

        -- Data In signal from SpaceWire bus.
        spw_di:     in  std_logic;

        -- Strobe In signal from SpaceWire bus.
        spw_si:     in  std_logic );

    -- Turn off FSM extraction.
    -- Without this, XST will happily apply one-hot encoding to rrx.headptr.
    attribute FSM_EXTRACT: string;
    attribute FSM_EXTRACT of spwrecvfront_fast: entity is "NO";

end entity spwrecvfront_fast;

architecture spwrecvfront_arch of spwrecvfront_fast is

    -- width of bit groups in cyclic buffer;
    -- typically equal to rxchunk, except when rxchunk = 1
    type memwidth_array_type is array(1 to 4) of integer;
    constant chunk_to_memwidth: memwidth_array_type := ( 2, 2, 3, 4 );
    constant memwidth: integer := chunk_to_memwidth(rxchunk);

    -- registers in rxclk domain
    type rxregs_type is record
        -- stage B: re-register input samples
        b_di0:      std_ulogic;
        b_si0:      std_ulogic;
        b_di1:      std_ulogic;
        b_si1:      std_ulogic;
        -- stage C: data/strobe decoding
        c_bit:      std_logic_vector(1 downto 0);
        c_val:      std_logic_vector(1 downto 0);
        c_xor1:     std_ulogic;
        -- stage D: collect groups of memwidth bits
        d_shift:    std_logic_vector(memwidth-1 downto 0);
        d_count:    std_logic_vector(memwidth-1 downto 0);
        -- cyclic buffer access
        bufdata:    std_logic_vector(memwidth-1 downto 0);
        bufwrite:   std_ulogic;
        headptr:    std_logic_vector(2 downto 0);
        -- activity detection
        bitcnt:     std_logic_vector(2 downto 0);
    end record;

    -- registers in system clock domain
    type regs_type is record
        -- data path from buffer to output
        tailptr:    std_logic_vector(2 downto 0);
        inbvalid:   std_ulogic;
        -- split 2-bit groups if rxchunk=1
        splitbit:   std_ulogic;
        splitinx:   std_ulogic;
        splitvalid: std_ulogic;
        -- activity detection
        bitcntp:    std_logic_vector(2 downto 0);
        inact:      std_ulogic;
        -- reset signal towards rxclk domain
        rxdis:      std_ulogic;
    end record;

    constant regs_reset: regs_type := (
        tailptr     => "000",
        inbvalid    => '0',
        splitbit    => '0',
        splitinx    => '0',
        splitvalid  => '0',
        bitcntp     => "000",
        inact       => '0',
        rxdis       => '1' );

    -- Signals that are re-synchronized from rxclk to system clock domain.
    type syncsys_type is record
        headptr:    std_logic_vector(2 downto 0);   -- pointer in cyclic buffer
        bitcnt:     std_logic_vector(2 downto 0);   -- activity detection
    end record;

    -- Registers.
    signal r:           regs_type := regs_reset;
    signal rin:         regs_type;
    signal rrx, rrxin:  rxregs_type;

    -- Synchronized signals after crossing clock domains.
    signal syncrx_rstn: std_logic;
    signal syncsys:     syncsys_type;

    -- Output data from cyclic buffer.
    signal s_bufdout:   std_logic_vector(memwidth-1 downto 0);

    -- stage A: input flip-flops for rising/falling rxclk
    signal s_a_di0:     std_logic;
    signal s_a_si0:     std_logic;
    signal s_a_di1:     std_logic;
    signal s_a_si1:     std_logic;
    signal s_a_di2:     std_logic;
    signal s_a_si2:     std_logic;

    -- force use of IOB flip-flops
    attribute IOB: string;
    attribute IOB of s_a_di1: signal is "TRUE";
    attribute IOB of s_a_si1: signal is "TRUE";
    attribute IOB of s_a_di2: signal is "TRUE";
    attribute IOB of s_a_si2: signal is "TRUE";

begin

    -- Cyclic data buffer.
    bufmem: spwram
        generic map (
            abits   => 3,
            dbits   => memwidth )
        port map (
            rclk    => clk,
            wclk    => rxclk,
            ren     => '1',
            raddr   => r.tailptr,
            rdata   => s_bufdout,
            wen     => rrx.bufwrite,
            waddr   => rrx.headptr,
            wdata   => rrx.bufdata );

    -- Synchronize reset signal for rxclk domain.
    syncrx_reset: syncdff
        port map ( clk => rxclk, rst => r.rxdis, di => '1', do => syncrx_rstn );

    -- Synchronize signals from rxclk domain to system clock domain.
    syncsys_headptr0: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.headptr(0), do => syncsys.headptr(0) );
    syncsys_headptr1: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.headptr(1), do => syncsys.headptr(1) );
    syncsys_headptr2: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.headptr(2), do => syncsys.headptr(2) );
    syncsys_bitcnt0: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.bitcnt(0), do => syncsys.bitcnt(0) );
    syncsys_bitcnt1: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.bitcnt(1), do => syncsys.bitcnt(1) );
    syncsys_bitcnt2: syncdff
        port map ( clk => clk, rst => r.rxdis, di => rrx.bitcnt(2), do => syncsys.bitcnt(2) );

    -- sample inputs on rising edge of rxclk
    process (rxclk) is
    begin
        if rising_edge(rxclk) then
            s_a_di1     <= spw_di;
            s_a_si1     <= spw_si;
        end if;
    end process;

    -- sample inputs on falling edge of rxclk
    process (rxclk) is
    begin
        if falling_edge(rxclk) then
            s_a_di2     <= spw_di;
            s_a_si2     <= spw_si;
            -- reregister inputs in fabric flip-flops
            s_a_di0     <= s_a_di2;
            s_a_si0     <= s_a_si2;
        end if;
    end process;

    -- combinatorial process
    process  (r, rrx, rxen, syncrx_rstn, syncsys, s_bufdout, s_a_di0, s_a_si0, s_a_di1, s_a_si1)
        variable v:     regs_type;
        variable vrx:   rxregs_type;
    begin
        v       := r;
        vrx     := rrx;

        -- ---- SAMPLE CLOCK DOMAIN ----

        -- stage B: re-register input samples
        vrx.b_di0   := s_a_di0;
        vrx.b_si0   := s_a_si0;
        vrx.b_di1   := s_a_di1;
        vrx.b_si1   := s_a_si1;

        -- stage C: decode data/strobe and detect valid bits
        if (rrx.b_di0 xor rrx.b_si0 xor rrx.c_xor1) = '1' then
            vrx.c_bit(0) := rrx.b_di0;
        else
            vrx.c_bit(0) := rrx.b_di1;
        end if;
        vrx.c_bit(1) := rrx.b_di1;
        vrx.c_val(0) := (rrx.b_di0 xor rrx.b_si0 xor rrx.c_xor1) or
                        (rrx.b_di0 xor rrx.b_si0 xor rrx.b_di1 xor rrx.b_si1);
        vrx.c_val(1) := (rrx.b_di0 xor rrx.b_si0 xor rrx.c_xor1) and
                        (rrx.b_di0 xor rrx.b_si0 xor rrx.b_di1 xor rrx.b_si1);
        vrx.c_xor1   := rrx.b_di1 xor rrx.b_si1;

        -- Note:
        -- c_val = "00" if no new bits are received
        -- c_val = "01" if one new bit is received; the new bit is in c_bit(0)
        -- c_val = "11" if two new bits are received

        -- stage D: collect groups of memwidth bits
        if rrx.c_val(0) = '1' then

            -- shift incoming bits into register
            if rrx.c_val(1) = '1' then
                vrx.d_shift := rrx.c_bit & rrx.d_shift(memwidth-1 downto 2);
            else
                vrx.d_shift := rrx.c_bit(0) & rrx.d_shift(memwidth-1 downto 1);
            end if;

            -- prepare to store a group of memwidth bits
            if rrx.d_count(0) = '1' then
                -- only one more bit needed
                vrx.bufdata := rrx.c_bit(0) & rrx.d_shift(memwidth-1 downto 1);
            else
                vrx.bufdata := rrx.c_bit & rrx.d_shift(memwidth-1 downto 2);
            end if;

            -- countdown nr of needed bits (one-hot counter)
            if rrx.c_val(1) = '1' then
                vrx.d_count := rrx.d_count(1 downto 0) & rrx.d_count(memwidth-1 downto 2);
            else
                vrx.d_count := rrx.d_count(0 downto 0) & rrx.d_count(memwidth-1 downto 1);
            end if;

        end if;

        -- stage D: store groups of memwidth bits
        vrx.bufwrite := rrx.c_val(0) and (rrx.d_count(0) or (rrx.c_val(1) and rrx.d_count(1)));

        -- Increment head pointer.
        if rrx.bufwrite = '1' then
            vrx.headptr := std_logic_vector(unsigned(rrx.headptr) + 1);
        end if;

        -- Activity detection.
        if rrx.c_val(0) = '1' then
            vrx.bitcnt  := std_logic_vector(unsigned(rrx.bitcnt) + 1);
        end if;

        -- Synchronous reset of rxclk domain.
        if syncrx_rstn = '0' then
            vrx.c_val   := "00";
            vrx.c_xor1  := '0';
            vrx.d_count := (others => '0');
            vrx.d_count(memwidth-1) := '1';
            vrx.bufwrite := '0';
            vrx.headptr := "000";
            vrx.bitcnt  := "000";
        end if;

        -- ---- SYSTEM CLOCK DOMAIN ----

        -- Compare tailptr to headptr to decide whether there is new data.
        -- If the values are equal, we are about to read a location which has
        -- not yet been written by the rxclk domain.
        if r.tailptr = syncsys.headptr then
            -- No more data in cyclic buffer.
            v.inbvalid  := '0';
        else
            -- Reading valid data from cyclic buffer.
            v.inbvalid  := '1';
            -- Increment tail pointer.
            if rxchunk /= 1 then
                v.tailptr   := std_logic_vector(unsigned(r.tailptr) + 1);
            end if;
        end if;

        -- If rxchunk=1, split 2-bit groups into separate bits.
        if rxchunk = 1 then
            -- Select one of the two bits.
            if r.splitinx = '0' then
                v.splitbit  := s_bufdout(0);
            else
                v.splitbit  := s_bufdout(1);
            end if;
            -- Indicate valid bit.
            v.splitvalid := r.inbvalid;
            -- Increment tail pointer.
            if r.inbvalid = '1' then
                v.splitinx   := not r.splitinx;
                if r.splitinx = '0' then
                    v.tailptr   := std_logic_vector(unsigned(r.tailptr) + 1);
                end if;
            end if;
        end if;

        -- Activity detection.
        v.bitcntp   := syncsys.bitcnt;
        if r.bitcntp = syncsys.bitcnt then
            v.inact     := '0';
        else
            v.inact     := '1';
        end if;

        -- Synchronous reset of system clock domain.
        if rxen = '0' then
            v   := regs_reset;
        end if;

        -- Register rxen to ensure glitch-free signal to rxclk domain
        v.rxdis     := not rxen;

        -- drive outputs
        inact       <= r.inact;
        if rxchunk = 1 then
            inbvalid    <= r.splitvalid;
            inbits(0)   <= r.splitbit;
        else
            inbvalid    <= r.inbvalid;
            inbits      <= s_bufdout;
        end if;

        -- update registers
        rrxin       <= vrx;
        rin         <= v;

    end process;

    -- update registers on rising edge of rxclk
    process (rxclk) is
    begin
        if rising_edge(rxclk) then
            rrx <= rrxin;
        end if;
    end process;

    -- update registers on rising edge of system clock
    process (clk) is
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture spwrecvfront_arch;
