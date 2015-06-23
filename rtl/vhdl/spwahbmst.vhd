--
--  AHB master for AMBA interface.
--
--  This is a helper entity for the SpaceWire AMBA interface.
--  It implements the AHB master which transfers data from/to main memory.
--
--  Descriptor flag bits on input:
--    bit 15:0      (RX) max nr of bytes to receive (must be a multiple of 4)
--                  (TX) nr of bytes to transmit
--    bit 16        EN: '1' = descriptor enabled
--    bit 17        WR: wrap to beginning of descriptor table
--    bit 18        IE: interrupt at end of descriptor
--    bit 19        '0'
--    bit 20        (TX only) send EOP after end of data
--    bit 21        (TX only) send EEP after end of data
--
--  Descriptor flag bits after completion of frame:
--    bit 15:0      (RX only) LEN: nr of bytes received
--                  (TX) undefined
--    bit 16        '0'
--    bit 18:17     undefined
--    bit 19        '1' to indicate descriptor completed       
---   bit 20        (RX only) received EOP after end of data
--    bit 21        (RX only) received EEP after end of data
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use work.spwambapkg.all;


entity spwahbmst is

    generic (
        -- AHB master index.
        hindex:         integer;

        -- AHB plug&play information.
        hconfig:        ahb_config_type;

        -- Maximum burst length as the 2-logarithm of the number of words.
        maxburst:       integer range 1 to 8
    );

    port (
        -- System clock.
        clk:        in  std_logic;

        -- Synchronous reset (active-low).
        rstn:       in  std_logic;

        -- Inputs from SpaceWire core.
        msti:       in  spw_ahbmst_in_type;

        -- Outputs to SpaceWire core.
        msto:       out spw_ahbmst_out_type;

        -- AHB master input signals.
        ahbi:       in  ahb_mst_in_type;

        -- AHB master output signals.
        ahbo:       out ahb_mst_out_type
    );

end entity spwahbmst;

architecture spwahbmst_arch of spwahbmst is

    --
    -- Registers.
    --

    type state_type is (
        st_idle,
        st_rxgetdesc, st_rxgetptr, st_rxtransfer, st_rxfinal, st_rxputdesc,
        st_txgetdesc, st_txgetptr, st_txtransfer, st_txfinal, st_txputdesc, st_txskip );

    type burst_state_type is ( bs_idle, bs_setup, bs_active, bs_end );

    type regs_type is record
        -- dma state
        rxdma_act:      std_ulogic;
        txdma_act:      std_ulogic;
        ahberror:       std_ulogic;
        -- main state machine
        mstate:         state_type;
        firstword:      std_ulogic;
        prefertx:       std_ulogic;
        -- rx descriptor state
        rxdes_en:       std_ulogic;
        rxdes_wr:       std_ulogic;
        rxdes_ie:       std_ulogic;
        rxdes_eop:      std_ulogic;
        rxdes_eep:      std_ulogic;
        rxdes_len:      std_logic_vector(13 downto 0);  -- in 32-bit words
        rxdes_pos:      std_logic_vector(15 downto 0);  -- in bytes
        rxaddr:         std_logic_vector(31 downto 2);
        rxdesc_next:    std_ulogic;
        -- tx descriptor state
        txdes_en:       std_ulogic;
        txdes_wr:       std_ulogic;
        txdes_ie:       std_ulogic;
        txdes_eop:      std_ulogic;
        txdes_eep:      std_ulogic;
        txdes_len:      std_logic_vector(15 downto 0);  -- in bytes
        txaddr:         std_logic_vector(31 downto 2);
        txdesc_next:    std_ulogic;
        -- interrupts
        int_rxdesc:     std_ulogic;
        int_txdesc:     std_ulogic;
        int_rxpacket:   std_ulogic;
        -- burst state
        burststat:      burst_state_type;
        hbusreq:        std_ulogic;
        hwrite:         std_ulogic;
        haddr:          std_logic_vector(31 downto 2);
        hwdata:         std_logic_vector(31 downto 0);
    end record;

    constant regs_reset: regs_type := (
        rxdma_act       => '0',
        txdma_act       => '0',
        ahberror        => '0',
        mstate          => st_idle,
        firstword       => '0',
        prefertx        => '0',
        rxdes_en        => '0',
        rxdes_wr        => '0',
        rxdes_ie        => '0',
        rxdes_eop       => '0',
        rxdes_eep       => '0',
        rxdes_len       => (others => '0'),
        rxdes_pos       => (others => '0'),
        rxaddr          => (others => '0'),
        rxdesc_next     => '0',
        txdes_en        => '0',
        txdes_wr        => '0',
        txdes_ie        => '0',
        txdes_eop       => '0',
        txdes_eep       => '0',
        txdes_len       => (others => '0'),
        txaddr          => (others => '0'),
        txdesc_next     => '0',
        int_rxdesc      => '0',
        int_txdesc      => '0',
        int_rxpacket    => '0',
        burststat       => bs_idle,
        hbusreq         => '0',
        hwrite          => '0',
        haddr           => (others => '0'),
        hwdata          => (others => '0') );

    signal r: regs_type := regs_reset;
    signal rin: regs_type;

begin

    --
    -- Combinatorial process
    --
    process (r, rstn, msti, ahbi)  is
        variable v:             regs_type;
        variable v_hrdata:      std_logic_vector(31 downto 0);
        variable v_burstreq:    std_logic;
        variable v_burstack:    std_logic;
        variable v_rxfifo_read: std_logic;
        variable v_txfifo_write: std_logic;
        variable v_txfifo_wdata: std_logic_vector(35 downto 0);
    begin
        v           := r;

        -- Decode AHB data bus (64-bit AHB compatibility).
        v_hrdata    := ahbreadword(ahbi.hrdata);

        -- Assume no burst request.
        v_burstreq  := '0';

        -- Detect request from burst state machine for next data word.
        v_burstack  := ahbi.hready and
                       conv_std_logic(r.burststat = bs_active or r.burststat = bs_end);

        -- Assume no fifo activity; take data for TX fifo from AHB bus.
        v_rxfifo_read   := '0';
        v_txfifo_write  := '0';
        v_txfifo_wdata(35 downto 32) := (others => '0');
        v_txfifo_wdata(31 downto 0)  := v_hrdata;

        -- Reset registers for interrupts and descriptor updates.
        v.int_rxdesc    := '0';
        v.int_txdesc    := '0';
        v.int_rxpacket  := '0';
        v.rxdesc_next   := '0';
        v.txdesc_next   := '0';

        -- Start DMA on external request.
        if msti.rxdma_start = '1' then v.rxdma_act := '1'; end if;
        if msti.txdma_start = '1' then v.txdma_act := '1'; end if;

        --
        -- Main state machine.
        --
        case r.mstate is

            when st_idle =>
                -- Waiting for something to do.
                v.prefertx  := '0';
                v.firstword := '1';
                if msti.txdma_cancel = '1' then
                    v.txdma_act := '0';
                    v.txdes_en  := '0';
                end if;
                if r.rxdma_act = '1' and msti.rxfifo_empty = '0' and
                   (r.prefertx = '0' or r.txdma_act = '0' or msti.txfifo_highw = '1') then
                    -- Start RX transfer.
                    if r.rxdes_en = '1' then
                        -- Transfer RX data to current descriptor.
                        v_burstreq  := '1';
                        v.hwrite    := '1';
                        v.haddr     := r.rxaddr;
                        v.mstate    := st_rxtransfer;
                    else
                        -- Must fetch new RX descriptor.
                        v_burstreq  := '1';
                        v.hwrite    := '0';
                        v.haddr     := msti.rxdesc_ptr & "0";
                        v.mstate    := st_rxgetdesc;
                    end if;
                elsif r.txdma_act = '1' and msti.txdma_cancel = '0' and msti.txfifo_highw = '0' then
                    -- Start TX transfer.
                    if r.txdes_en = '1' then
                        -- Transfer TX data from current descriptor.
                        if unsigned(r.txdes_len) = 0 then
                            -- Only send EOP/EEP and write back descriptor.
                            v_burstreq  := '1';
                            v.hwrite    := '1';
                            v.haddr     := msti.txdesc_ptr & "0";
                            v.txdesc_next := '1';
                            v.mstate    := st_txputdesc;
                        else
                            -- Start burst transfer.
                            v_burstreq  := '1';
                            v.hwrite    := '0';
                            v.haddr     := r.txaddr;
                            if unsigned(r.txdes_len) <= 4 then
                                -- Transfer only one word.
                                v.mstate    := st_txfinal;
                            else
                                v.mstate    := st_txtransfer;
                            end if;
                        end if;
                    else
                        -- Must fetch new TX descriptor.
                        v_burstreq  := '1';
                        v.hwrite    := '0';
                        v.haddr     := msti.txdesc_ptr & "0";
                        v.mstate    := st_txgetdesc;
                    end if;
                end if;

            when st_rxgetdesc =>
                -- Read RX descriptor flags from memory.
                v_burstreq  := '1';
                v.hwrite    := '0';
                v.rxdes_len := v_hrdata(15 downto 2);
                v.rxdes_en  := v_hrdata(16);
                v.rxdes_wr  := v_hrdata(17);
                v.rxdes_ie  := v_hrdata(18);
                v.rxdes_eop := '0';
                v.rxdes_eep := '0';
                v.rxdes_pos := (others => '0');
                if v_burstack = '1' then
                    -- Got descriptor flags.
                    v_burstreq  := '0';
                    v.mstate    := st_rxgetptr;
                end if;

            when st_rxgetptr =>
                -- Read RX data pointer from memory.
                v.rxaddr    := v_hrdata(31 downto 2);
                v.haddr     := v_hrdata(31 downto 2);
                v.firstword := '1';
                if v_burstack = '1' then
                    -- Got data pointer.
                    if r.rxdes_en = '1' then
                        -- Start transfer.
                        v_burstreq  := '1';
                        v.hwrite    := '1';
                        v.mstate    := st_rxtransfer;
                    else
                        -- Reached end of valid descriptors; stop.
                        v.rxdma_act := '0';
                        v.mstate    := st_idle;
                    end if;
                end if;

            when st_rxtransfer =>
                -- Continue an RX transfer.
                v_burstreq  := '1';
                v.hwrite    := '1';
                v.firstword := '0';
                if v_burstack = '1' or r.firstword = '1' then
                    -- Setup first/next data word.
                    v.hwdata    := msti.rxfifo_rdata(31 downto 0);
                    v_rxfifo_read := '1';
                    -- Update pointers.
                    v.rxdes_len := std_logic_vector(unsigned(r.rxdes_len) - 1);
                    v.rxdes_pos := std_logic_vector(unsigned(r.rxdes_pos) + 4);
                    v.rxaddr    := std_logic_vector(unsigned(r.rxaddr) + 1);
                    -- Detect EOP/EEP.
                    v.rxdes_eop :=
                        (msti.rxfifo_rdata(35) and not msti.rxfifo_rdata(24)) or
                        (msti.rxfifo_rdata(34) and not msti.rxfifo_rdata(16)) or
                        (msti.rxfifo_rdata(33) and not msti.rxfifo_rdata(8)) or
                        (msti.rxfifo_rdata(32) and not msti.rxfifo_rdata(0));
                    v.rxdes_eep :=
                        (msti.rxfifo_rdata(35) and msti.rxfifo_rdata(24)) or
                        (msti.rxfifo_rdata(34) and msti.rxfifo_rdata(16)) or
                        (msti.rxfifo_rdata(33) and msti.rxfifo_rdata(8)) or
                        (msti.rxfifo_rdata(32) and msti.rxfifo_rdata(0));
                    -- Adjust frame length in case of EOP/EEP.
                    if msti.rxfifo_rdata(35) = '1' then
                        v.rxdes_pos := r.rxdes_pos(r.rxdes_pos'high downto 2) & "00";
                    elsif msti.rxfifo_rdata(34) = '1' then
                        v.rxdes_pos := r.rxdes_pos(r.rxdes_pos'high downto 2) & "01";
                    elsif msti.rxfifo_rdata(33) = '1' then
                        v.rxdes_pos := r.rxdes_pos(r.rxdes_pos'high downto 2) & "10";
                    elsif msti.rxfifo_rdata(32) = '1' then
                        v.rxdes_pos := r.rxdes_pos(r.rxdes_pos'high downto 2) & "11";
                    end if;
                    -- Stop at end of requested length or end of packet or fifo empty.
                    if msti.rxfifo_nxempty = '1' or
                       orv(msti.rxfifo_rdata(35 downto 32)) = '1' or
                       unsigned(r.rxdes_len) = 1 then
                        v_burstreq  := '0';
                        v.mstate    := st_rxfinal;
                    end if;
                    -- Stop at max burst length boundary.
                    if (andv(r.rxaddr(maxburst+1 downto 2)) = '1') then
                        v_burstreq  := '0';
                        v.mstate    := st_rxfinal;
                    end if;
                end if;

            when st_rxfinal =>
                -- Last data cycle of an RX transfer.
                if v_burstack = '1' then
                    if unsigned(r.rxdes_len) = 0 or
                       r.rxdes_eop = '1' or r.rxdes_eep = '1' then
                        -- End of frame; write back descriptor.
                        v_burstreq  := '1';
                        v.hwrite    := '1';
                        v.haddr     := msti.rxdesc_ptr & "0";
                        v.rxdesc_next := '1';
                        v.mstate    := st_rxputdesc;
                    else
                        -- Go through st_idle to pick up more work.
                        v.mstate    := st_idle;
                    end if;
                end if;
                -- Give preference to TX work since we just did some RX work.
                v.prefertx  := '1';

            when st_rxputdesc =>
                -- Write back RX descriptor.
                v.hwdata(15 downto 0) := r.rxdes_pos;
                v.hwdata(16)  := '0';
                v.hwdata(17)  := r.rxdes_wr;
                v.hwdata(18)  := r.rxdes_ie;
                v.hwdata(19)  := '1';
                v.hwdata(20)  := r.rxdes_eop;
                v.hwdata(21)  := r.rxdes_eep;
                v.hwdata(31 downto 22) := (others => '0');
                if v_burstack = '1' then
                    -- Frame done.
                    v.rxdes_en      := '0';
                    v.int_rxdesc    := r.rxdes_ie;
                    v.int_rxpacket  := r.rxdes_eop or r.rxdes_eep;
                    -- Go to st_idle.
                    v.mstate    := st_idle;
                end if;

            when st_txgetdesc =>
                -- Read TX descriptor flags from memory.
                v_burstreq  := '1';
                v.hwrite    := '0';
                v.txdes_len := v_hrdata(15 downto 0);
                v.txdes_en  := v_hrdata(16);
                v.txdes_wr  := v_hrdata(17);
                v.txdes_ie  := v_hrdata(18);
                v.txdes_eop := v_hrdata(20);
                v.txdes_eep := v_hrdata(21);
                if v_burstack = '1' then
                    -- Got descriptor flags.
                    v_burstreq  := '0';
                    v.mstate    := st_txgetptr;
                end if;

            when st_txgetptr =>
                -- Read TX data pointer from memory.
                v.txaddr    := v_hrdata(31 downto 2);
                if v_burstack = '1' then
                    -- Got data pointer.
                    if r.txdes_en = '1' then
                        -- Start transfer.
                        if unsigned(r.txdes_len) = 0 then
                            -- Only send EOP/EEP and write back descriptor.
                            v_burstreq  := '1';
                            v.hwrite    := '1';
                            v.haddr     := msti.txdesc_ptr & "0";
                            v.txdesc_next := '1';
                            v.mstate    := st_txputdesc;
                        else
                            v_burstreq  := '1';
                            v.hwrite    := '0';
                            v.haddr     := v_hrdata(31 downto 2);
                            if unsigned(r.txdes_len) <= 4 then
                                -- Transfer only one word.
                                v.mstate    := st_txfinal;
                            else
                                v.mstate    := st_txtransfer;
                            end if;
                        end if;
                    else
                        -- Reached end of valid descriptors; stop.
                        v.txdma_act := '0';
                        v.mstate    := st_idle;
                    end if;
                end if;

            when st_txtransfer =>
                -- Continue an TX transfer.
                v_burstreq  := '1';
                v.hwrite    := '0';
                if v_burstack = '1' then
                    -- Got next data word from memory.
                    v_txfifo_write  := '1';
                    -- Update pointers.
                    v.txdes_len := std_logic_vector(unsigned(r.txdes_len) - 4);
                    v.txaddr    := std_logic_vector(unsigned(r.txaddr) + 1);
                    -- Handle end of burst/transfer.
                    if andv(r.txaddr(maxburst+1 downto 2)) = '1' then
                        -- This was the last data cycle before the max burst boundary.
                        -- Go through st_idle to pick up more work.
                        v_burstreq  := '0';
                        v.mstate    := st_idle;
                    elsif msti.txfifo_nxfull = '1' then
                        -- Fifo full; stop transfer, ignore final data cycle.
                        v_burstreq  := '0';
                        v.mstate    := st_txskip;
                    elsif unsigned(r.txdes_len) <= 8 then
                        -- Stop at end of requested length (one more data cycle).
                        v_burstreq  := '0';
                        v.mstate    := st_txfinal;
                    elsif andv(r.txaddr(maxburst+1 downto 3)) = '1' then
                        -- Stop at max burst length boundary (one more data cycle).
                        v_burstreq  := '0';
                    end if;
                else
                    if andv(r.txaddr(maxburst+1 downto 2)) = '1' then
                        -- Stop at max burst length boundary (just one more data cycle).
                        v_burstreq  := '0';
                    end if;
                end if;

            when st_txfinal =>
                -- Last data cycle of a TX descriptor (1 <= txdes_len <= 4).
                if v_burstack = '1' then
                    -- Got last data word from memory.
                    v_txfifo_write  := '1';
                    v.txdes_len := std_logic_vector(unsigned(r.txdes_len) - 4);
                    -- Insert EOP in last word if needed.
                    -- (Or set bit 7 in the flag byte to indicate that the
                    --  frame ends while the packet continues.)
                    case r.txdes_len(1 downto 0) is
                        when "01" =>
                            v_txfifo_wdata(34)  := '1';
                            v_txfifo_wdata(23)  := not (r.txdes_eop or r.txdes_eep);
                            v_txfifo_wdata(22 downto 17) := "000000";
                            v_txfifo_wdata(16)  := r.txdes_eep;
                        when "10" =>
                            v_txfifo_wdata(33)  := '1';
                            v_txfifo_wdata(15)  := not (r.txdes_eop or r.txdes_eep);
                            v_txfifo_wdata(14 downto 9) := "000000";
                            v_txfifo_wdata(8)   := r.txdes_eep;
                        when "11" =>
                            v_txfifo_wdata(32)  := '1';
                            v_txfifo_wdata(7)   := not (r.txdes_eop or r.txdes_eep);
                            v_txfifo_wdata(6 downto 1) := "000000";
                            v_txfifo_wdata(0)   := r.txdes_eep;
                        when others =>
                            -- txdes_len = 4
                            -- Store 4 data bytes now; store EOP in st_txputdesc (if needed).
                    end case;
                    if msti.txfifo_nxfull = '1' and r.txdes_len(1 downto 0) = "00" then
                        -- Fifo full so no room to store EOP.
                        v.mstate    := st_idle;
                        v.haddr     := msti.txdesc_ptr & "0";
                    else
                        -- Prepare to write back descriptor.
                        v_burstreq  := '1';
                        v.hwrite    := '1';
                        v.haddr     := msti.txdesc_ptr & "0";
                        v.txdesc_next := '1';
                        v.mstate    := st_txputdesc;
                    end if;
                end if;

            when st_txputdesc =>
                -- Write back TX descriptor.
                v.hwdata(15 downto 0) := (others => '0');
                v.hwdata(16)  := '0';
                v.hwdata(17)  := r.txdes_wr;
                v.hwdata(18)  := r.txdes_ie;
                v.hwdata(19)  := '1';
                v.hwdata(20)  := r.txdes_eop;
                v.hwdata(21)  := r.txdes_eep;
                v.hwdata(31 downto 22) := (others => '0');
                if v_burstack = '1' then
                    if r.txdes_len(1 downto 0) = "00" and
                       (r.txdes_eop = '1' or r.txdes_eep = '1') then
                        -- Store EOP in TX fifo.
                        v_txfifo_write  := '1';
                        v_txfifo_wdata(35)  := '1';
                        v_txfifo_wdata(31 downto 25) := "0000000";
                        v_txfifo_wdata(24)  := r.txdes_eep;
                    end if;
                    -- Frame done.
                    v.txdes_en  := '0';
                    v.int_txdesc  := r.txdes_ie;
                    -- Go to st_idle and give preference to RX work.
                    v.mstate    := st_idle;
                end if;

            when st_txskip =>
                -- Ignore last data cycle of burst because TX fifo is full.
                if v_burstack = '1' then
                    v.mstate    := st_idle;
                end if;

        end case;

        -- Abort DMA when an AHB error occurs.
        if r.ahberror = '1' then
            v.rxdma_act := '0';
            v.txdma_act := '0';
            v.mstate    := st_idle;
        end if;


        --
        -- Burst state machine.
        --
        -- A transfer starts when the main state machine combinatorially pulls
        -- v_burstreq high and assigns v.haddr and v.hwrite (i.e. r.haddr and
        -- r.hwrite must be valid in the first clock cycle AFTER rising v_burstreq).
        -- In case of a write transfer, r.hwdata must be valid in the second
        -- clock cycle after rising v_burstreq.
        --
        -- During the transfer, the burst state machine announces each word
        -- with a v_burstack pulse. During a read transfer, ahbi.hrdata is
        -- valid when v_burstack is high. During a write transfer, a next
        -- word must be assigned to v.hwdata on the v_burstack pulse.
        --
        -- For a single-word transfer, v_burstreq should be high for only one
        -- clock cycle. For a multi-word transfer, v_burstreq should be high
        -- until the last-but-one v_burstack pulse. I.e. after v_burstreq is
        -- released combinatorially on a v_burstack pulse, one last v_burstack
        -- pulse will follow.
        --
        -- The burst state machine transparently handles bus arbitration and
        -- retrying of transfers. In case of a non-retryable error, r.ahberror
        -- is set high and further transfers are blocked. The main state
        -- machine is responsible for ensuring that bursts do not cross a
        -- forbidden address boundary.
        --
        case r.burststat is

            when bs_idle =>
                -- Wait for request and bus grant.
                -- (htrans = HTRANS_IDLE)
                v.hbusreq   := r.hbusreq or v_burstreq;
                if (r.hbusreq = '1' or v_burstreq = '1') and
                   ahbi.hready = '1' and
                   ahbi.hgrant(hindex) = '1' then
                    -- Start burst.
                    v.burststat := bs_setup;
                end if;
                -- Block new bursts after an error occurred.
                if r.ahberror = '1' then
                    v.hbusreq   := '0';
                    v.burststat := bs_idle;
                end if;

            when bs_setup =>
                -- First address cycle.
                -- (htrans = HTRANS_NONSEQ)
                v.hbusreq   := '1';
                if ahbi.hready = '1' then
                    -- Increment address and continue burst in bs_active.
                    v.haddr(maxburst+1 downto 2) := std_logic_vector(unsigned(r.haddr(maxburst+1 downto 2)) + 1);
                    v.burststat := bs_active;
                    -- Stop burst when application ends the transfer.
                    v.hbusreq   := v_burstreq;
                    if v_burstreq = '0' then
                        v.burststat := bs_end;
                    end if;
                    -- Stop burst when we are kicked off the bus.
                    if ahbi.hgrant(hindex) = '0' then
                        v.burststat := bs_end;
                    end if;
                end if;

            when bs_active =>
                -- Continue burst.
                -- (htrans = HTRANS_SEQ)
                v.hbusreq   := '1';
                if ahbi.hresp /= HRESP_OKAY then
                    -- Error response from slave.
                    v.haddr(maxburst+1 downto 2) := std_logic_vector(unsigned(r.haddr(maxburst+1 downto 2)) - 1);
                    if ahbi.hresp = HRESP_ERROR then
                        -- Permanent error.
                        v.ahberror  := '1';
                        v.hbusreq   := '0';
                    else
                        -- Must retry request.
                        v.hbusreq   := '1';
                    end if;
                    v.burststat := bs_idle;
                elsif ahbi.hready = '1' then
                    -- Increment address.
                    v.haddr(maxburst+1 downto 2) := std_logic_vector(unsigned(r.haddr(maxburst+1 downto 2)) + 1);
                    -- Stop burst when application ends the transfer.
                    v.hbusreq   := v_burstreq;
                    if v_burstreq = '0' then
                        v.burststat := bs_end;
                    end if;
                    -- Stop burst when we are kicked off the bus.
                    if ahbi.hgrant(hindex) = '0' then
                        v.burststat := bs_end;
                    end if;
                end if;

            when bs_end =>
                -- Last data cycle of burst.
                -- (htrans = HTRANS_IDLE)
                v.hbusreq   := r.hbusreq or v_burstreq;
                if ahbi.hresp /= HRESP_OKAY then
                    -- Error response from slave.
                    v.haddr(maxburst+1 downto 2) := std_logic_vector(unsigned(r.haddr(maxburst+1 downto 2)) - 1);
                    if ahbi.hresp = HRESP_ERROR then
                        -- Permanent error.
                        v.ahberror  := '1';
                        v.hbusreq   := '0';
                    else
                        -- Must retry request.
                        v.hbusreq   := '1';
                    end if;
                    v.burststat := bs_idle;
                elsif ahbi.hready = '1' then
                    -- Burst complete.
                    if (r.hbusreq = '1' or v_burstreq = '1') and
                       ahbi.hgrant(hindex) = '1' then
                        -- Immediately start next burst.
                        v.burststat := bs_setup;
                    else
                        v.burststat := bs_idle;
                    end if;
                end if;

        end case;


        --
        -- Drive output signals.
        --
        ahbo.hbusreq    <= r.hbusreq;
        if r.burststat = bs_setup then
            ahbo.htrans     <= HTRANS_NONSEQ;
        elsif r.burststat = bs_active then
            ahbo.htrans     <= HTRANS_SEQ;
        else
            ahbo.htrans     <= HTRANS_IDLE;
        end if;
        ahbo.haddr      <= r.haddr & "00";
        ahbo.hwrite     <= r.hwrite;
        ahbo.hwdata     <= ahbdrivedata(r.hwdata);
        ahbo.hlock      <= '0';             -- never lock the bus
        ahbo.hsize      <= HSIZE_WORD;      -- always 32-bit words
        ahbo.hburst     <= HBURST_INCR;     -- undetermined incremental burst
        ahbo.hprot      <= "0011";          -- not cacheable, privileged, data
        ahbo.hirq       <= (others => '0'); -- no interrupts via AHB bus
        ahbo.hconfig    <= hconfig;         -- AHB plug&play data
        ahbo.hindex     <= hindex;          -- index feedback

        msto.rxdma_act      <= r.rxdma_act;
        msto.txdma_act      <= r.txdma_act;
        msto.ahberror       <= r.ahberror;
        msto.int_rxdesc     <= r.int_rxdesc;
        msto.int_txdesc     <= r.int_txdesc;
        msto.int_rxpacket   <= r.int_rxpacket;
        msto.rxdesc_next    <= r.rxdesc_next;
        msto.rxdesc_wrap    <= r.rxdesc_next and r.rxdes_wr;
        msto.txdesc_next    <= r.txdesc_next;
        msto.txdesc_wrap    <= r.txdesc_next and r.txdes_wr;
        msto.rxfifo_read    <= v_rxfifo_read;
        msto.txfifo_write   <= v_txfifo_write;
        msto.txfifo_wdata   <= v_txfifo_wdata;


        --
        -- Reset.
        --
        if rstn = '0' then
            v   := regs_reset;
        end if;


        --
        -- Update registers.
        --
        rin <= v;
    end process;


    --
    -- Synchronous process: update registers.
    --
    process (clk) is
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;

end architecture spwahbmst_arch;
