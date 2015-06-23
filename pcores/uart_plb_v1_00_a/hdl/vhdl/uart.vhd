-- $Id$
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.uart_components.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
    generic (DATA_BITS        : integer);
    Port (
        rst                   : in  std_logic;
        clk                   : in  std_logic;
        dlw                   : in  std_logic_vector(15 downto 0);
        --
        tx_wr                 : in  std_logic;   -- pulse signal
        tx_fifo_reset         : in  std_logic;   -- pulse signal
        tx_din                : in  std_logic_vector(DATA_BITS-1 downto 0);
        tx_fifo_full          : out std_logic;   -- level signal
        tx_fifo_almost_full   : out std_logic;   -- level signal
        tx_fifo_empty         : out std_logic;   -- level signal
        tx_fifo_almost_empty  : out std_logic;   -- level signal
        tx_xmt_empty          : out std_logic;   -- level signal, transmit shift register empty
        --
        rx_rd                 : in  std_logic;   -- pulse signal
        rx_fifo_reset         : in  std_logic;   -- pulse signal
        rx_dout               : out std_logic_vector(DATA_BITS-1 downto 0);
        rx_fifo_full          : out std_logic;   -- level signal
        rx_fifo_almost_full   : out std_logic;   -- level signal
        rx_fifo_empty         : out std_logic;   -- level signal
        rx_fifo_almost_empty  : out std_logic;   -- level signal
        rx_timeout            : out std_logic;   -- pulse signal
        --
        tx_sout               : out std_logic;
        rx_sin                : in  std_logic
     );
end uart;

architecture rtl of uart is

-------- BaudRate -----------
signal tick_s : std_logic;
-------- TXD ----------------
type   tx_state_type is (stTxIDLE, stTxDoWRITE, stTxDoREAD, stTxDONE);
signal ctxstate, ntxstate : tx_state_type;
signal xmt_done_s         : std_logic;
signal xmt_wr_s           : std_logic;
signal tx_fifo_rd_s       : std_logic;
signal tx_fifo_empty_s    : std_logic;
signal tx_fifo_dout_s     : std_logic_vector(DATA_BITS-1 downto 0);
-------- RXD ----------------
signal rcv_done_s         : std_logic := '0';
signal rcv_dout_s         : std_logic_vector(DATA_BITS-1 downto 0) := (others=>'0');

signal tx_fifo_reset_s    : std_logic;
signal rx_fifo_reset_s    : std_logic;

begin

-------- BaudRate -----------
baud_gen : baudrate
    port map (
        clk          => clk,
        rst          => rst,
        dlw          => dlw,
        tick         => tick_s
    );

------------ TXD -------------------
tx : xmt
    generic map (DATA_BITS => DATA_BITS)
    port map (
        clk          => clk,
        rst          => rst,
        tick         => tick_s,
        wr           => xmt_wr_s,
        din          => tx_fifo_dout_s,
        sout         => tx_sout,
        done         => xmt_done_s
    );

    tx_fifo_reset_s <= tx_fifo_reset or rst;
    
tx_fifo_8x16 : fifo_generator_v8_1_8x16
    PORT MAP (
        clk          => clk,
        srst         => tx_fifo_reset_s,
        din          => tx_din,
        wr_en        => tx_wr,
        rd_en        => tx_fifo_rd_s,
        dout         => tx_fifo_dout_s,
        full         => tx_fifo_full,
        almost_full  => tx_fifo_almost_full,
        empty        => tx_fifo_empty_s,
        almost_empty => tx_fifo_almost_empty
    );

    tx_xmt_empty  <= xmt_done_s;
    tx_fifo_empty <= tx_fifo_empty_s;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ctxstate <= stTxIDLE;
            else
                ctxstate <= ntxstate;
            end if;
        end if;
    end process;

    process(xmt_done_s, tx_fifo_empty_s, ctxstate)
    begin
        ntxstate <= ctxstate;
        case ctxstate is
            when stTxIDLE    =>
                if (xmt_done_s = '1' and tx_fifo_empty_s = '0') then
                    ntxstate <= stTxDoWRITE;
                end if;
            when stTxDoWRITE => ntxstate <= stTxDoREAD;
            when stTxDoREAD  => ntxstate <= stTxDONE;
            when stTxDONE    => ntxstate <= stTxIDLE;
        end case;
    end process;

    process(ctxstate)
    begin
        xmt_wr_s <= '0';
        tx_fifo_rd_s <= '0';
        case ctxstate is
            when stTxDoWRITE => xmt_wr_s <= '1';
            when stTxDoREAD  => tx_fifo_rd_s <= '1';
            when others      => null;
        end case;
    end process;


------------ RXD -------------------

timeout : tmo
    Port map (
        clk          => clk,
        clr          => rcv_done_s,
        tick         => tick_s,
        timeout      => rx_timeout
    );

rx : rcv
    generic map (DATA_BITS => DATA_BITS)
    port map (
        clk          => clk,
        rst          => rst,
        tick         => tick_s,
        sin          => rx_sin,
        dout         => rcv_dout_s,
        done         => rcv_done_s
    );

    rx_fifo_reset_s <= rx_fifo_reset or rst;

rx_fifo_8x16 : fifo_generator_v8_1_8x16
    PORT MAP (
        clk          => clk,
        srst         => rx_fifo_reset_s,
        din          => rcv_dout_s,
        wr_en        => rcv_done_s,
        rd_en        => rx_rd,
        dout         => rx_dout,
        full         => rx_fifo_full,
        almost_full  => rx_fifo_almost_full,
        empty        => rx_fifo_empty,
        almost_empty => rx_fifo_almost_empty
    );

end rtl;
