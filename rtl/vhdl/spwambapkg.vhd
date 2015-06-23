--
--  VHDL package for SpaceWire AMBA interface.
--
--  This package depends on Gaisler GRLIB.
--

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
use work.spwpkg.all;

package spwambapkg is


    -- AMBA plug&play device id
    constant DEVICE_SPACEWIRELIGHT: amba_device_type := 16#131#;


    -- Signals from SpaceWire core to AHB master.
    type spw_ahbmst_in_type is record

        -- Pulse high to start the RX DMA engine.
        rxdma_start:    std_ulogic;

        -- Pulse high to start the TX DMA engine.
        txdma_start:    std_ulogic;

        -- Stop TX DMA engine (at end of current burst).
        txdma_cancel:   std_ulogic;

        -- Address of current RX descriptor (8-byte aligned).
        rxdesc_ptr:     std_logic_vector(31 downto 3);

        -- Address of current TX descriptor (8-byte aligned).
        txdesc_ptr:     std_logic_vector(31 downto 3);

        -- Read port of RX FIFO.
        rxfifo_rdata:   std_logic_vector(35 downto 0);

        -- High if RX FIFO is empty.
        rxfifo_empty:   std_ulogic;

        -- High if RX FIFO will be empty after one read.
        -- May combinatorially depend on spw_ahbmst_out_type.rxfifo_read.
        rxfifo_nxempty: std_ulogic;

        -- High if TX FIFO is full or has room for at most one word.
        txfifo_nxfull:  std_ulogic;

        -- High if TX FIFO is close to full (blocks refill).
        txfifo_highw:   std_ulogic;
    end record;

    -- Signals from AHB master to SpaceWire core.
    type spw_ahbmst_out_type is record

        -- High if the RX DMA engine is enabled.
        rxdma_act:      std_ulogic;

        -- High if the TX DMA engine is enabled.
        txdma_act:      std_ulogic;

        -- High if an error occurred on the AHB bus.
        ahberror:       std_ulogic;

        -- Pulsed high to trigger an RX descriptor interrupt.
        int_rxdesc:     std_ulogic;

        -- Pulsed high to trigger a TX descriptor interrupt.
        int_txdesc:     std_ulogic;

        -- Pulsed high when a complete packet has been received.
        int_rxpacket:   std_ulogic;

        -- Pulsed high to request the next RX descriptor address.
        -- (rxdesc_ptr must be updated in the next clock cycle).
        rxdesc_next:    std_ulogic;

        -- Pulsed high together with rxdesc_next to wrap the RX descriptor pointer.
        rxdesc_wrap:    std_ulogic;

        -- Pulsed high to request the next TX descriptor address.
        -- (txdesc_ptr must be updated in the next clock cycle).
        txdesc_next:    std_ulogic;

        -- Pulsed high together with txdesc_next to wrap the TX descriptor pointer.
        txdesc_wrap:    std_ulogic;

        -- Read strobe to RX fifo.
        rxfifo_read:    std_ulogic;

        -- Write enable to TX fifo.
        txfifo_write:   std_ulogic;

        -- Input port of TX fifo.
        txfifo_wdata:   std_logic_vector(35 downto 0);
    end record;


    -- SpaceWire core with AMBA interface.
    component spwamba is
        generic (
            tech:           integer range 0 to NTECH := DEFFABTECH;
            hindex:         integer;                -- AHB master index
            pindex:         integer;                -- APB slave index
            paddr:          integer;                -- APB address range
            pmask:          integer := 16#fff#;     -- APB address mask
            pirq:           integer;                -- interrupt number
            sysfreq:        real;                   -- system clock frequency in Hz
            txclkfreq:      real := 0.0;            -- txclk frequency in Hz
            rximpl:         spw_implementation_type := impl_generic;
            rxchunk:        integer range 1 to 4 := 1;
            tximpl:         spw_implementation_type := impl_generic;
            timecodegen:    boolean := true;        -- support timecode generation
            rxfifosize:     integer range 6 to 12 := 8; -- size of receive FIFO (2-log of words)
            txfifosize:     integer range 2 to 12 := 8; -- size of transmit FIFO (2-log of words)
            desctablesize:  integer range 4 to 14 := 10; -- size of the DMA descriptor tables (2-log of descriptors)
            maxburst:       integer range 1 to 8 := 3   -- max burst length (2-log of words)
        );
        port (
            clk:        in  std_logic;              -- system clock.
            rxclk:      in  std_logic;              -- receiver sample clock
            txclk:      in  std_logic;              -- transmit clock
            rstn:       in  std_logic;              -- synchronous reset (active-low)
            apbi:       in  apb_slv_in_type;        -- APB slave input signals
            apbo:       out apb_slv_out_type;       -- APB slave output signals
            ahbi:       in  ahb_mst_in_type;        -- AHB master input signals
            ahbo:       out ahb_mst_out_type;       -- AHB master output signals
            tick_in:    in  std_logic;              -- pulse for timecode generation
            tick_out:   out std_logic;              -- timecode received
            spw_di:     in  std_logic;              -- Data In signal from SpaceWire bus
            spw_si:     in  std_logic;              -- Strobe In signal from SpaceWire bus
            spw_do:     out std_logic;              -- Data Out signal to SpaceWire bus
            spw_so:     out std_logic               -- Strobe Out signal to SpaceWire bus
        );
    end component spwamba;


    -- AHB master for AMBA interface.
    component spwahbmst is
        generic (
            hindex:         integer;                -- AHB master index
            hconfig:        ahb_config_type;        -- AHB plug&play information
            maxburst:       integer range 1 to 8    -- 2log of max burst length
        );
        port (
            clk:        in  std_logic;              -- system clock
            rstn:       in  std_logic;              -- synchronous reset (active-low)
            msti:       in  spw_ahbmst_in_type;     -- inputs from SpaceWire core
            msto:       out spw_ahbmst_out_type;    -- outputs to SpaceWire core
            ahbi:       in  ahb_mst_in_type;        -- AHB master input signals
            ahbo:       out ahb_mst_out_type        -- AHB master output signals
        );
    end component spwahbmst;

end package;
